/* ---------------------------------------

Location Filter Logic (dropdowns)

Notes: 

- There's a plugin being used for the selectboxes that necessitates
  a call to their method for the change event to work
  See more on this on their Github readme: 
  https://github.com/marcj/jquery-selectBox

*/




module.exports = function() {

  updateUrl()

}




updateUrl = function() {


  // Listen for location selections
  // and perform necessary logic

  $('#locationFilter select').selectBox().change(function () {

      // Get the id of the selected location 

      var targetURL = $(this).val()

      
      // navigate the window to the new url

      window.location = targetURL

  })

}