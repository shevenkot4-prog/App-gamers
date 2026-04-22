enum CharacterClass {
  knight(displayName: 'Caballero', dbValue: 'knight'),
  vagabond(displayName: 'Vagabundo', dbValue: 'vagabond'),
  sorcerer(displayName: 'Hechicero', dbValue: 'sorcerer');

  const CharacterClass({
    required this.displayName,
    required this.dbValue,
  });

  final String displayName;
  final String dbValue;
}
