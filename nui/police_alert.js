$(document).ready(function() {
    let currentAlert = null;
    let autoHideTimer = null;
    let alertSound = null;

    // Précharger le son
    try {
        alertSound = new Audio('../sounds/police_alert.ogg');
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

    // Fonction pour afficher l'alerte
    function showAlert(data) {
        currentAlert = data;

        // Mettre à jour les informations
        $('#alertLocation').text(data.location || 'Position inconnue');
        $('#alertTime').text(data.time || 'Il y a quelques instants');

        // Afficher l'alerte
        $('#policeAlert').removeClass('hiding').fadeIn(300);

        // Redémarrer l'animation de la barre de progression
        $('#progressBar').css('animation', 'none');
        setTimeout(() => {
            $('#progressBar').css('animation', 'progressDecrease 15s linear');
        }, 10);

        // Auto-hide après 15 secondes
        clearTimeout(autoHideTimer);
        autoHideTimer = setTimeout(() => {
            declineAlert();
        }, 15000);
    }

    // Fonction pour cacher l'alerte
    function hideAlert() {
        $('#policeAlert').addClass('hiding');
        setTimeout(() => {
            $('#policeAlert').hide().removeClass('hiding');
        }, 400);

        clearTimeout(autoHideTimer);
        currentAlert = null;
    }

    // Fonction pour accepter l'alerte
    function acceptAlert() {
        if (!currentAlert) return;

        // Envoyer au client Lua
        $.post('https://zsell/acceptPoliceAlert', JSON.stringify({
            coords: currentAlert.coords
        }));

        // Feedback visuel
        $('.button-hint.accept').css({
            'background': 'rgba(34, 197, 94, 0.5)',
            'transform': 'scale(1.1)'
        });

        setTimeout(() => {
            hideAlert();
        }, 300);
    }

    // Fonction pour refuser l'alerte
    function declineAlert() {
        if (!currentAlert) return;

        // Envoyer au client Lua
        $.post('https://zsell/declinePoliceAlert', JSON.stringify({}));

        // Feedback visuel
        $('.button-hint.decline').css({
            'background': 'rgba(239, 68, 68, 0.5)',
            'transform': 'scale(1.1)'
        });

        setTimeout(() => {
            hideAlert();
        }, 300);
    }

    // Gestion des touches clavier
    $(document).keyup(function(e) {
        if (!$('#policeAlert').is(':visible')) return;

        if (e.key === "e" || e.key === "E") {
            acceptAlert();
        } else if (e.key === "x" || e.key === "X") {
            declineAlert();
        }
    });

    // Click sur les boutons
    $('.button-hint.accept').click(function() {
        acceptAlert();
    });

    $('.button-hint.decline').click(function() {
        declineAlert();
    });
});
