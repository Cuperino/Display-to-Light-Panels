#include "displaywindow.h"
#include "./ui_displaywindow.h"

DisplayWindow::DisplayWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::DisplayWindow)
    , m_hue(180)
    , m_lightness(250)
    , m_saturation(255)
{
    ui->setupUi(this);

    // Hide disabled button used to create symmetry
    auto invisibleButton = ui->invisibleButtonToCenterRow;
    QSizePolicy sizePolicyRetain = invisibleButton->sizePolicy();
    sizePolicyRetain.setRetainSizeWhenHidden(true);
    invisibleButton->setSizePolicy(sizePolicyRetain);
    invisibleButton->hide();

#ifdef Q_OS_MACX
    // Hide option for feature not implemented by MacOS
    ui->alwaysOnBackButton->hide();
#endif

    updateColor();
    showMaximized();
}

DisplayWindow::~DisplayWindow()
{
    delete ui;
}

void DisplayWindow::on_hue_valueChanged(int val)
{
    m_hue = val;
    updateColor();
}


void DisplayWindow::on_lightness_valueChanged(int val)
{
    m_lightness = val;
    updateColor();
}


void DisplayWindow::on_saturation_valueChanged(int val)
{
    m_saturation = val;
    updateColor();
}

void DisplayWindow::updateColor() {
    m_backgroundColor.setHsl(m_hue, m_saturation, m_lightness);
    // m_backgroundColor.setHsv(m_hue, m_saturation, m_lightness);
    auto a = qApp;
    QPalette pal = a->palette();
    pal.setColor(QPalette::Window, m_backgroundColor);
    a->setPalette(pal);
}

void DisplayWindow::on_whiteButton_clicked()
{
    m_lightness = 255;
    ui->lightness->setValue(m_lightness);
}

void DisplayWindow::on_alwaysOnTopButton_clicked()
{
    if (this->isFullScreen())
        this->setWindowState(Qt::WindowMaximized);
    if (!this->windowFlags().testFlag(Qt::WindowStaysOnTopHint)) {
        this->setWindowFlags(Qt::Window | Qt::WindowStaysOnTopHint);
        this->show();
    }
}

void DisplayWindow::on_normalWindowButton_clicked()
{
    if (this->isFullScreen())
        this->setWindowState(Qt::WindowMaximized);
    if (this->windowFlags().testFlag(Qt::WindowStaysOnTopHint) ||
        this->windowFlags().testFlag(Qt::WindowStaysOnBottomHint)) {
        this->setWindowFlags(Qt::Window);
        this->show();
    }
}

void DisplayWindow::on_alwaysOnBackButton_clicked()
{
    if (this->isFullScreen())
        this->setWindowState(Qt::WindowMaximized);
    // MacOS doesn't implement StaysOnBottom
    if (!this->windowFlags().testFlag(Qt::WindowStaysOnBottomHint)) {
        this->setWindowFlags(Qt::Window | Qt::WindowStaysOnBottomHint);
        this->show();
    }
}

void DisplayWindow::on_fullScreenButton_clicked()
{
    this->setWindowState(Qt::WindowFullScreen);
}
