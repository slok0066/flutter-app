import 'package:flutter/material.dart';
import '../models/progress_data.dart';

class ProgressChart extends StatelessWidget {
  final ProgressData progress;

  const ProgressChart({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final weekData = _getWeekData();
    final maxValue = weekData.isEmpty ? 1.0 : weekData.reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final value = index < weekData.length ? weekData[index] : 0.0;
              final height = maxValue > 0 ? (value / maxValue) * 120 : 0.0;
              final dayName = _getDayName(index);
              final isToday = _isToday(index);
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label
                  if (value > 0)
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    )
                  else
                    const SizedBox(height: 14),
                  
                  const SizedBox(height: 4),
                  
                  // Bar
                  Container(
                    width: 24,
                    height: height.clamp(4.0, 120.0),
                    decoration: BoxDecoration(
                      color: isToday 
                          ? Theme.of(context).primaryColor
                          : value > 0 
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Day label
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday 
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: Theme.of(context).primaryColor,
              label: 'Learning Hours',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.grey[300]!,
              label: 'No Activity',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<double> _getWeekData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = <double>[];
    
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final sessionsOnDay = progress.sessionDates.where((date) =>
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day).length;
      
      // Estimate 0.5 hours per session
      weekData.add(sessionsOnDay * 0.5);
    }
    
    return weekData;
  }

  String _getDayName(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }

  bool _isToday(int index) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final day = weekStart.add(Duration(days: index));
    
    return day.year == now.year &&
           day.month == now.month &&
           day.day == now.day;
  }
}

