class XpEngine {
  static int calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  static int xpForNextLevel(int xp) {
    int nextLevel = calculateLevel(xp) + 1;
    return (nextLevel - 1) *
        100; // Returns total XP needed for next level. e.g., Level 1 -> next Level 2 -> requires 100 total XP
  }
}
