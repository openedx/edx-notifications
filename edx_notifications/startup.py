"""
File to support the startup of the Notification subsystem. This should be called
at least once at the beginning of any process lifecycle
"""

from edx_notifications.signals import perform_type_registrations

# This is unfortunate, but to have the standard Open edX
# NotificationTypes get registered on startup we have
# to import the modules, otherwise, they will
# not register their Django signal receivers

# pylint: disable=duplicate-code

from edx_notifications.openedx import forums  # pylint: disable=unused-import
from edx_notifications.openedx import course_announcements  # pylint: disable=unused-import


def initialize():
    """
    Startup entry point for the Notification subsystem
    """

    # alert the application tiers that they should register their
    # notification types
    perform_type_registrations.send(sender=None)
