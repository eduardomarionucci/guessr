String normalizeAnswer(String value) {
  const accents = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const plain = 'aaaaaeeeeiiiiooooouuuuc';
  var result = value.toLowerCase().trim();
  for (var i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], plain[i]);
  }
  return result.replaceAll(RegExp(r'\s+'), ' ');
}
