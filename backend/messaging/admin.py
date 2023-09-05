from django.contrib import admin

from messaging.models import Location, Message, OfficialMessage

admin.site.register(Location)


class MessageAdmin(admin.ModelAdmin):
    list_display = ("content", "sent", "location")
    list_filter = ("sent", "location")
    search_fields = ("content",)


admin.site.register(Message, MessageAdmin)


class OfficialMessageAdmin(admin.ModelAdmin):
    list_display = ("content", "sent", "locations")
    list_filter = ("sent", "locations")
    search_fields = ("content",)


admin.site.register(OfficialMessage, OfficialMessageAdmin)
