# -*- coding: utf-8 -*-
# Generated by Django 1.11.5 on 2018-07-09 07:55
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    def insertpartnertype(apps, schema_editor):
        PartnerType = apps.get_model("assessments", "PartnerType")
        partnertype = PartnerType.objects.create(char_id="primary",description= "Partner with Data")
        partnertype = PartnerType.objects.create(char_id="secondary", description="Partner with No Data")

    dependencies = [
        ('boundary', '0021_boundarystatecode_language'),
        ('assessments', '0054_questionblankvalues_1108'),
    ]

    operations = [
        migrations.CreateModel(
            name='PartnerBoundaryMap',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('boundary', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='boundary.Boundary')),
            ],
        ),
        migrations.CreateModel(
            name='PartnerType',
            fields=[
                ('char_id', models.CharField(max_length=20, primary_key=True, serialize=False)),
                ('description', models.CharField(max_length=50)),
            ],
        ),
        migrations.RunPython(insertpartnertype),
        migrations.AddField(
            model_name='partner',
            name='logo_file',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
        migrations.AddField(
            model_name='partner',
            name='website',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='partnerboundarymap',
            name='partner',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='assessments.Partner'),
        ),
        migrations.AddField(
            model_name='partner',
            name='partner_type',
            field=models.ForeignKey(default='primary', on_delete=django.db.models.deletion.CASCADE, to='assessments.PartnerType'),
        ),
        migrations.AlterUniqueTogether(
            name='partnerboundarymap',
            unique_together=set([('partner', 'boundary')]),
        ),
    ]
