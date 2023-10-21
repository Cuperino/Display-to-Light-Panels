#ifndef INTERNALMESSAGEBROKER_H
#define INTERNALMESSAGEBROKER_H

#include <QObject>

class InternalMessageBroker : public QObject
{
    Q_OBJECT

private:
    // Hide regular constructor
    InternalMessageBroker() = default;
    static InternalMessageBroker *self;

public:
    // Disable copy constructor
    InternalMessageBroker(const InternalMessageBroker& obj) = delete;
    InternalMessageBroker& operator=(InternalMessageBroker const&) = delete;
    static std::shared_ptr<InternalMessageBroker> instance()
    {
        static std::shared_ptr<InternalMessageBroker> sharedPtr{new InternalMessageBroker};
        return sharedPtr;
    }

signals:
    void hueChanged(int, bool);
    void lightnessChanged(int, bool);
    void saturationChanged(int, bool);
};

#endif // INTERNALMESSAGEBROKER_H
