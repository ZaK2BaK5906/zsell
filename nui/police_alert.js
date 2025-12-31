$(document).ready(function() {
    let autoHideTimer = null;
    let alertSound = null;

    // Précharger le son
    try {
        alertSound = new Audio('police_alert.ogg');
        alertSound.volume = 0.5;
    } catch(e) {
        console.log('Son non disponible:', e);
    }

    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.type) {
            case 'showPoliceAlert':
                showAlert(data);
                break;
            case 'hidePoliceAlert':
                hideAlert();
                break;
            case 'playSound':
                playAlertSound();
                break;
        }
    });

    // Fonction pour jouer le son
    function playAlertSound() {
        if (alertSound) {
            alertSound.currentTime = 0;
            alertSound.play().catch(e => {
                console.log('Impossible de jouer le son:', e);
            });
        }
    }

    // Fonction pour afficher l'alerte (GPS activé automatiquement)
    function showAlert(data) {
        console.log('[POLICE ALERT] showAlert appelée', data);

        // Mettre à jour les informations
        $('#alertLocation').text(data.location || 'Position inconnue');
        $('#alertTime').text(data.time || 'Il y a quelques instants');

        console.log('[POLICE ALERT] Affichage de l\'alerte');
        // Afficher l'alerte
        $('#policeAlert').removeClass('hiding').fadeIn(300);

        // Redémarrer l'animation de la barre de progression (5 secondes)
        $('#progressBar').css('animation', 'none');
        setTimeout(() => {
            $('#progressBar').css('animation', 'progressDecrease 5s linear');
        }, 10);

        // Auto-hide après 5 secondes
        clearTimeout(autoHideTimer);
        autoHideTimer = setTimeout(() => {
            hideAlert();
        }, 5000);
    }

    // Fonction pour cacher l'alerte
    function hideAlert() {
        $('#policeAlert').addClass('hiding');
        setTimeout(() => {
            $('#policeAlert').hide().removeClass('hiding');
        }, 400);

        clearTimeout(autoHideTimer);
    }
});
