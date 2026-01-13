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

// Global değişken: Aktif Chart örneğini tutmak için (Yoksa üst üste biner)
var activeModalChart = null;

// 1. MODAL (POPUP) FONKSİYONLARI
function openHistoryModal(modalId, canvasId, labels, data, chartLabel, hourLabel) {
  var modal = document.getElementById(modalId);
  if (modal) {
    modal.style.display = "block";
    
    // Eğer grafik parametreleri geldiyse grafiği çiz
    if (canvasId && labels && data) {
      drawModalChart(canvasId, labels, data, chartLabel, hourLabel);
    }
  }
}

function closeHistoryModal(id) {
  var modal = document.getElementById(id);
  if (modal) {
    modal.style.display = "none";
  }
  // Modalı kapatınca chart'ı yok et (hafıza temizliği)
  if (activeModalChart) {
    activeModalChart.destroy();
    activeModalChart = null;
  }
}

// Popup İçi Grafik Çizici
function drawModalChart(canvasId, labels, data, chartLabel, hourLabel) {
  var ctxElement = document.getElementById(canvasId);
  if (!ctxElement) return;

  var ctx = document.getElementById(canvasId).getContext('2d');
  
  // Önceki grafik varsa sil (Yoksa mouse üzerine gelince titrer)
  if (activeModalChart) {
    activeModalChart.destroy();
  }

  activeModalChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: chartLabel,
        data: data,
        backgroundColor: 'rgba(54, 162, 235, 0.6)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          title: { 
            display: true, 
            text: hourLabel
          }
        }
      },
      plugins: {
        legend: { display: true },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.parsed.y + ' ' + hourLabel;
            }
          }
        }
      }
    }
  });
}

// Pencere dışına tıklayınca kapatma
window.onclick = function(event) {
  if (event.target.className === 'custom-modal') {
    event.target.style.display = "none";
    if (activeModalChart) { activeModalChart.destroy(); activeModalChart = null; }
  }
}

// 2. SAYFA YÜKLENDİĞİNDE ÇALIŞACAK GRAFİKLER (Genel Raporlar)
document.addEventListener("DOMContentLoaded", function() {
  
  // --- A) Ana Durum Grafiği (Doughnut) ---
  var statusCanvas = document.getElementById('statusChart');
  if (statusCanvas) {
    new Chart(statusCanvas.getContext('2d'), {
      type: 'doughnut',
      data: {
        labels: JSON.parse(statusCanvas.dataset.labels),
        datasets: [{
          label: 'İş Sayısı',
          data: JSON.parse(statusCanvas.dataset.values),
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40']
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false, 
        plugins: { 
          title: { display: false }, 
          legend: { position: 'bottom' } 
        }
      }
    });
  }

  // --- B) Kategori Grafiği (Pie) ---
  var categoryCanvas = document.getElementById('categoryChart');
  if (categoryCanvas) {
    new Chart(categoryCanvas.getContext('2d'), {
      type: 'pie',
      data: {
        labels: JSON.parse(categoryCanvas.dataset.labels),
        datasets: [{
          data: JSON.parse(categoryCanvas.dataset.values),
          backgroundColor: ['#FF9F40', '#FF6384', '#4BC0C0', '#FFCE56', '#36A2EB']
        }]
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false, 
        plugins: { 
          title: { display: false }, 
          legend: { position: 'bottom' }
        }
      }
    });
  }

  // --- C) Kullanıcı Grafiği (Bar) ---
  var userCanvas = document.getElementById('userChart');
  if (userCanvas) {
    new Chart(userCanvas.getContext('2d'), {
      type: 'bar',
      data: {
        labels: JSON.parse(userCanvas.dataset.labels),
        datasets: [{
          label: 'Üzerindeki İş Sayısı',
          data: JSON.parse(userCanvas.dataset.values),
          backgroundColor: '#36A2EB',
          maxBarThickness: 50
        }]
      },
      options: { 
        responsive: true, 
        maintainAspectRatio: false, 
        plugins: { 
          title: { display: false },
          legend: { display: false } 
        },
        scales: {
          y: { beginAtZero: true, ticks: { precision: 0 } }
        }
      }
    });
  }
});