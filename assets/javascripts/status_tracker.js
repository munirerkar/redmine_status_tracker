function openHistoryModal(id) {
  var modal = document.getElementById(id);
  if (modal) {
    modal.style.display = "block";
  }
}

function closeHistoryModal(id) {
  var modal = document.getElementById(id);
  if (modal) {
    modal.style.display = "none";
  }
}

window.onclick = function(event) {
  if (event.target.className === 'custom-modal') {
    event.target.style.display = "none";
  }
}

document.addEventListener("DOMContentLoaded", function() {
  var ctxCanvas = document.getElementById('statusChart');

  if (ctxCanvas) {
    var rawLabels = ctxCanvas.dataset.labels;
    var rawValues = ctxCanvas.dataset.values;

    if (rawLabels && rawValues) {
      var etiketler = JSON.parse(rawLabels);
      var veriler = JSON.parse(rawValues);

      new Chart(ctxCanvas.getContext('2d'), {
        type: 'doughnut',
        data: {
          labels: etiketler,
          datasets: [{
            label: 'İş Sayısı',
            data: veriler,
            borderWidth: 1,
            backgroundColor: [
              '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40'
            ]
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { position: 'bottom' },
            title: {display: true}
          }
        }
      });
    }
  }
});


// SCROLL KONUMUNU HATIRLAMA (Scroll Preservation)

document.addEventListener("DOMContentLoaded", function() {
  var scrollKey = 'redmine_status_tracker_scroll';

  var savedPosition = sessionStorage.getItem(scrollKey);

  if (savedPosition) {
   
    window.scrollTo(0, parseInt(savedPosition));
    
    sessionStorage.removeItem(scrollKey);
  }

  var sortLinks = document.querySelectorAll('table.list th a');
  
  sortLinks.forEach(function(link) {
    link.addEventListener('click', function() {
      sessionStorage.setItem(scrollKey, window.scrollY);
    });
  });

  var pageLinks = document.querySelectorAll('div.pagination a');
  pageLinks.forEach(function(link) {
    link.addEventListener('click', function() {
      sessionStorage.setItem(scrollKey, window.scrollY);
    });
  });
});
