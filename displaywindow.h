#ifndef DISPLAYWINDOW_H
#define DISPLAYWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class DisplayWindow; }
QT_END_NAMESPACE

class DisplayWindow : public QMainWindow
{
    Q_OBJECT

public:
    DisplayWindow(QWidget *parent = nullptr);
    ~DisplayWindow();

    QColor m_backgroundColor;

private slots:
    void on_hue_valueChanged(int val);
    void on_lightness_valueChanged(int val);
    void on_saturation_valueChanged(int val);
    void on_whiteButton_clicked();
    void on_alwaysOnTopButton_clicked();
    void on_normalWindowButton_clicked();
    void on_alwaysOnBackButton_clicked();
    void on_fullScreenButton_clicked();

private:
    Ui::DisplayWindow *ui;
    int m_hue;
    int m_lightness;
    int m_saturation;

    void updateColor();
};
#endif // DISPLAYWINDOW_H
