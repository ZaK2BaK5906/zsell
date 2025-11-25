$(document).ready(function() {
    let availableDrugs = [];
    let selectedDrug = null;
    let translations = {};

    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.type) {
            case 'openUI':
                openUI(data);
                break;
        }
    });

    // Fonction pour ouvrir l'interface
    function openUI(data) {
        availableDrugs = data.drugs;
        translations = data.translations;

        // Mettre à jour les traductions
        $('#headerTitle').text(translations.title);
        $('#mainTitle').text(translations.title);
        $('#subtitle').text(translations.subtitle);
        $('#quantityLabel').text(translations.quantity);
        $('#priceLabel').text(translations.price);
        $('#totalLabel').text(translations.total);

        // Réinitialiser l'interface
        $('#drugOptions').show();
        $('#negotiationPanel').hide();
        selectedDrug = null;

        // Générer les cartes de drogue
        generateDrugCards();

        // Afficher l'interface
        $('#app').fadeIn(300);
    }

    // Fonction pour générer les cartes de drogue
    function generateDrugCards() {
        const container = $('#drugOptions');
        container.empty();

        availableDrugs.forEach((drug, index) => {
            // Déterminer l'icône en fonction du type
            let icon = 'fa-pills';
            let iconClass = '';

            if (drug.item.includes('weed')) {
                icon = 'fa-cannabis';
                iconClass = 'weed';
            } else if (drug.item.includes('cocaine')) {
                icon = 'fa-prescription-bottle';
                iconClass = 'cocaine';
            } else if (drug.item.includes('meth')) {
                icon = 'fa-flask';
                iconClass = 'meth';
            }

            const card = `
                <div class="drug-card" data-index="${index}">
                    <div class="drug-icon ${iconClass}">
                        <i class="fas ${icon}"></i>
                    </div>
                    <div class="drug-content">
                        <h3>${drug.label}</h3>
                        <div class="drug-info">
                            <div class="info-row">
                                <span class="info-label">Stock:</span>
                                <span>${drug.count} pochons</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Prix min:</span>
                                <span>$${drug.minPrice}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Prix max:</span>
                                <span>$${drug.maxPrice}</span>
                            </div>
                        </div>
                        <button class="select-drug-btn">
                            <i class="fas fa-check-circle"></i>
                            <span>${translations.select}</span>
                        </button>
                    </div>
                </div>
            `;

            container.append(card);
        });

        // Attacher les événements
        $('.drug-card').click(function() {
            const index = $(this).data('index');
            selectDrug(index);
        });
    }

    // Fonction pour sélectionner une drogue
    function selectDrug(index) {
        selectedDrug = availableDrugs[index];

        // Masquer les options et afficher le panneau de négociation
        $('#drugOptions').fadeOut(200, function() {
            showNegotiationPanel();
            $('#negotiationPanel').fadeIn(300);
        });
    }

    // Fonction pour afficher le panneau de négociation
    function showNegotiationPanel() {
        // Mettre à jour les informations
        $('#selectedDrugName').text(selectedDrug.label);
        $('#selectedDrugStock span').text(selectedDrug.count);
        $('#minPrice').text('$' + selectedDrug.minPrice);
        $('#maxPrice').text('$' + selectedDrug.maxPrice);

        // Configurer les inputs
        const defaultPrice = Math.floor((selectedDrug.minPrice + selectedDrug.maxPrice) / 2);
        $('#quantityInput').attr('max', selectedDrug.count).val(1);
        $('#priceInput').attr('min', selectedDrug.minPrice).attr('max', selectedDrug.maxPrice).val(defaultPrice);

        // Mettre à jour l'icône
        let icon = 'fa-pills';
        let iconClass = '';

        if (selectedDrug.item.includes('weed')) {
            icon = 'fa-cannabis';
            $('.drug-icon-large').css('background', 'linear-gradient(135deg, #11998e, #38ef7d)');
        } else if (selectedDrug.item.includes('cocaine')) {
            icon = 'fa-prescription-bottle';
            $('.drug-icon-large').css('background', 'linear-gradient(135deg, #ee0979, #ff6a00)');
        } else if (selectedDrug.item.includes('meth')) {
            icon = 'fa-flask';
            $('.drug-icon-large').css('background', 'linear-gradient(135deg, #4facfe, #00f2fe)');
        }

        $('.drug-icon-large i').removeClass().addClass('fas ' + icon);

        // Mettre à jour le total et l'indicateur
        updateTotal();
        updatePriceIndicator();
    }

    // Fonction pour mettre à jour le total
    function updateTotal() {
        const quantity = parseInt($('#quantityInput').val()) || 1;
        const price = parseInt($('#priceInput').val()) || 0;
        const total = quantity * price;

        $('#totalAmount').text('$' + total.toLocaleString());
    }

    // Fonction pour mettre à jour l'indicateur de prix
    function updatePriceIndicator() {
        const price = parseInt($('#priceInput').val()) || 0;
        const min = selectedDrug.minPrice;
        const max = selectedDrug.maxPrice;

        const percentage = ((price - min) / (max - min)) * 100;
        $('#priceIndicator').css('width', percentage + '%');

        let text = '';
        let color = '';

        if (percentage <= 40) {
            text = 'Prix très bas - Très forte chance de vente';
            color = '#11998e';
        } else if (percentage <= 60) {
            text = 'Prix équilibré - Bonne chance de vente';
            color = '#f5af19';
        } else if (percentage <= 80) {
            text = 'Prix élevé - Risque de refus';
            color = '#ff9800';
        } else {
            text = 'Prix très élevé - Fort risque de refus ou vol !';
            color = '#ee0979';
        }

        $('#indicatorText').text(text).css('color', color);
    }

    // Events handlers
    $('#closeBtn').click(function() {
        closeUI();
    });

    $('#backBtn').click(function() {
        $('#negotiationPanel').fadeOut(200, function() {
            $('#drugOptions').fadeIn(300);
            selectedDrug = null;
        });
    });

    $('#negotiateBtn').click(function() {
        if (!selectedDrug) return;

        const quantity = parseInt($('#quantityInput').val()) || 1;
        const price = parseInt($('#priceInput').val()) || 0;

        // Valider
        if (quantity < 1 || quantity > selectedDrug.count) {
            return;
        }

        if (price < selectedDrug.minPrice || price > selectedDrug.maxPrice) {
            return;
        }

        // Animation du bouton
        $(this).html('<i class="fas fa-spinner fa-spin"></i><span>Négociation...</span>').prop('disabled', true);

        // Envoyer au client Lua
        $.post('https://zsell/startNegotiation', JSON.stringify({
            drug: selectedDrug.item,
            price: price,
            quantity: quantity
        }));

        // Fermer l'interface après un court délai
        setTimeout(() => {
            closeUI();
        }, 500);
    });

    // Mettre à jour le total quand on change les valeurs
    $('#quantityInput, #priceInput').on('input', function() {
        updateTotal();
        updatePriceIndicator();
    });

    // Fermer avec ESC
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#app').is(':visible')) {
                closeUI();
            }
        }
    });

    // Fonction pour fermer l'interface
    function closeUI() {
        $('#app').fadeOut(300);

        // Réinitialiser le bouton de négociation
        $('#negotiateBtn').html('<i class="fas fa-handshake"></i><span id="negotiateBtnText">Négocier</span>').prop('disabled', false);

        // Envoyer un message au client Lua
        $.post('https://zsell/closeUI', JSON.stringify({}));
    }

    // Effets hover
    $(document).on('mouseenter', '.drug-card', function() {
        $(this).addClass('hover-effect');
    });

    $(document).on('mouseleave', '.drug-card', function() {
        $(this).removeClass('hover-effect');
    });
});
