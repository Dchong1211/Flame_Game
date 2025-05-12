bool checkCollision(player, block) {
  final hitbox = player.hitbox;

  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  // Tính toạ độ gốc của player (anchor center)
  final playerCenterX = player.position.x;
  final playerCenterY = player.position.y;

  // Lật trái/phải ảnh hưởng đến offsetX
  final offsetX = player.scale.x < 0
      ? -hitbox.offsetX // Lật trái thì offset cũng lật
      : hitbox.offsetX;

  // Tính toạ độ cạnh hitbox
  final playerLeft = playerCenterX + offsetX - playerWidth / 2;
  final playerTop = playerCenterY + hitbox.offsetY - playerHeight / 2;
  final playerRight = playerLeft + playerWidth;
  final playerBottom = playerTop + playerHeight;

  // Toạ độ block
  final blockLeft = block.x;
  final blockTop = block.y;
  final blockRight = blockLeft + block.width;
  final blockBottom = blockTop + block.height;

  // Va chạm
  return (playerLeft < blockRight &&
      playerRight > blockLeft &&
      playerTop < blockBottom &&
      playerBottom > blockTop);
}
