// Snap Backup

var app = {
   hamburgerMenu: function() {
      var menuItem = $('main').data().menu;  //use "data-menu" attribute to set current menu item
      $('nav.hamburger-menu li[data-menu=' + menuItem + ']').addClass('current');
      },
   setup: function() {
      var macVersion = library.browser.macOS() && dna.browser.getUrlParams().view !== 'all';
      $('.for-macs-only').toggle(macVersion);
      $('.for-non-macs').toggle(!macVersion);
      }
   };

$(app.setup);
