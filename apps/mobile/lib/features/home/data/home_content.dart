import 'package:flutter/material.dart';

class HealthcareService {
  const HealthcareService({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String route;
  final Color color;
}

const healthcareServices = [
  HealthcareService(
    icon: Icons.medication_outlined,
    title: 'Buy Medicines',
    route: '/medicines',
    color: Color(0xFF009B8E),
  ),
  HealthcareService(
    icon: Icons.description_outlined,
    title: 'Prescription',
    route: '/prescription',
    color: Color(0xFF2563EB),
  ),
  HealthcareService(
    icon: Icons.medical_services_outlined,
    title: 'Doctors',
    route: '/doctors',
    color: Color(0xFF7C3AED),
  ),
  HealthcareService(
    icon: Icons.biotech_outlined,
    title: 'Lab Tests',
    route: '/labs',
    color: Color(0xFFDB2777),
  ),
  HealthcareService(
    icon: Icons.folder_shared_outlined,
    title: 'Records',
    route: '/records',
    color: Color(0xFFEA580C),
  ),
  HealthcareService(
    icon: Icons.shield_outlined,
    title: 'Insurance',
    route: '/insurance',
    color: Color(0xFF0F766E),
  ),
  HealthcareService(
    icon: Icons.favorite_border,
    title: 'Circle',
    route: '/circle',
    color: Color(0xFFBE123C),
  ),
];
