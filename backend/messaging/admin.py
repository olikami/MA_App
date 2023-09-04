from django.contrib import admin

from messaging.models import Location, Message

admin.site.register(Location)


class MessageAdmin(admin.ModelAdmin):
    list_display = ("content", "sent", "location")
    list_filter = ("sent", "location")
    search_fields = ("content",)


admin.site.register(Message, MessageAdmin)
