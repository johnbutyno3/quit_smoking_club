enum ContentCategory { reading, medical, stories, music, youtube, games }

class ContentCategoryParser {
  static ContentCategory fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'reading':
        return ContentCategory.reading;
      case 'medical':
        return ContentCategory.medical;
      case 'stories':
        return ContentCategory.stories;
      case 'music':
        return ContentCategory.music;
      case 'youtube':
        return ContentCategory.youtube;
      case 'games':
        return ContentCategory.games;
      default:
        return ContentCategory.reading;
    }
  }
}
