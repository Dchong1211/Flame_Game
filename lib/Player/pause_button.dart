import 'package:flutter/material.dart';
import '../Main/main_menu.dart';

/*
TODO: Có thể điều chỉnh thêm trong tương lai:
1. Thêm hiệu ứng âm thanh khi nhấn pause
2. Thêm animation fade in/out cho menu pause
3. Thêm tùy chọn Settings trong menu pause:
   - Điều chỉnh âm lượng
   - Độ nhạy của controls
   - Độ sáng màn hình
4. Thêm tùy chọn Save Game trong menu pause
5. Thêm hiệu ứng blur background khi pause
6. Thêm thông tin game (level, điểm số) trong menu pause
7. Tối ưu hóa giao diện cho các kích thước màn hình khác nhau
*/

class PauseButton extends StatelessWidget {
  const PauseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 30,
      top: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Resume Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Resume',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Main Menu Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainMenu()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Main Menu',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(
              Icons.pause_rounded,
              color: Color.fromRGBO(255, 255, 255, 0.7),
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}