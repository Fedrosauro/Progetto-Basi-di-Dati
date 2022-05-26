function toggleTable(string_value) {
  document.getElementById(string_value).classList.toggle("hidden");
}

function toggleEvent(){
  var sel = document.getElementById("selezione");
  var selectedValue = sel.options[sel.selectedIndex].value;
  toggleTable(selectedValue);
}
