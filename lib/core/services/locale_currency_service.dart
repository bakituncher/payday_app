/// Locale-based Currency Detection Service
/// Automatically detects user's country and assigns appropriate currency
/// Supports all countries with comprehensive locale-to-currency mapping

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class LocaleCurrencyService {
  static final LocaleCurrencyService _instance = LocaleCurrencyService._internal();
  factory LocaleCurrencyService() => _instance;
  LocaleCurrencyService._internal();

  /// Detect currency based on device locale
  /// Returns currency code (e.g., 'USD', 'EUR', 'TRY')
  String detectCurrency() {
    try {
      // Get device locale
      final locale = _getDeviceLocale();
      final countryCode = locale.countryCode?.toUpperCase() ?? '';

      if (countryCode.isEmpty) {
        return 'USD'; // Default fallback
      }

      // Map country code to currency
      final currency = _countryCurrencyMap[countryCode];

      if (currency != null) {
        debugPrint('✅ Detected country: $countryCode → Currency: $currency');
        return currency;
      }

      debugPrint('⚠️ Unknown country code: $countryCode, defaulting to USD');
      return 'USD';

    } catch (e) {
      debugPrint('❌ Error detecting currency: $e');
      return 'USD';
    }
  }

  /// Get device locale
  ui.Locale _getDeviceLocale() {
    try {
      // Try to get system locale
      final locale = ui.PlatformDispatcher.instance.locale;
      return locale;
    } catch (e) {
      debugPrint('Error getting device locale: $e');
      return const ui.Locale('en', 'US');
    }
  }

  /// Get country name from country code
  String getCountryName(String countryCode) {
    return _countryNames[countryCode.toUpperCase()] ?? countryCode;
  }

  /// Comprehensive country-to-currency mapping
  /// Covers all countries and territories worldwide
  static const Map<String, String> _countryCurrencyMap = {
    // Americas
    'US': 'USD', // United States
    'CA': 'CAD', // Canada
    'MX': 'MXN', // Mexico
    'BR': 'BRL', // Brazil
    'AR': 'ARS', // Argentina
    'CL': 'CLP', // Chile
    'CO': 'COP', // Colombia
    'PE': 'PEN', // Peru
    'VE': 'VES', // Venezuela
    'EC': 'USD', // Ecuador (uses USD)
    'BO': 'BOB', // Bolivia
    'PY': 'PYG', // Paraguay
    'UY': 'UYU', // Uruguay
    'GY': 'GYD', // Guyana
    'SR': 'SRD', // Suriname
    'GF': 'EUR', // French Guiana
    'CR': 'CRC', // Costa Rica
    'PA': 'PAB', // Panama
    'SV': 'USD', // El Salvador
    'GT': 'GTQ', // Guatemala
    'HN': 'HNL', // Honduras
    'NI': 'NIO', // Nicaragua
    'BZ': 'BZD', // Belize
    'CU': 'CUP', // Cuba
    'DO': 'DOP', // Dominican Republic
    'HT': 'HTG', // Haiti
    'JM': 'JMD', // Jamaica
    'TT': 'TTD', // Trinidad and Tobago
    'BB': 'BBD', // Barbados
    'BS': 'BSD', // Bahamas
    'LC': 'XCD', // Saint Lucia
    'GD': 'XCD', // Grenada
    'VC': 'XCD', // Saint Vincent
    'AG': 'XCD', // Antigua and Barbuda
    'DM': 'XCD', // Dominica
    'KN': 'XCD', // Saint Kitts and Nevis

    // Europe
    'GB': 'GBP', // United Kingdom
    'IE': 'EUR', // Ireland
    'FR': 'EUR', // France
    'DE': 'EUR', // Germany
    'IT': 'EUR', // Italy
    'ES': 'EUR', // Spain
    'PT': 'EUR', // Portugal
    'NL': 'EUR', // Netherlands
    'BE': 'EUR', // Belgium
    'LU': 'EUR', // Luxembourg
    'AT': 'EUR', // Austria
    'CH': 'CHF', // Switzerland
    'LI': 'CHF', // Liechtenstein
    'MC': 'EUR', // Monaco
    'VA': 'EUR', // Vatican City
    'SM': 'EUR', // San Marino
    'AD': 'EUR', // Andorra
    'MT': 'EUR', // Malta
    'CY': 'EUR', // Cyprus
    'GR': 'EUR', // Greece
    'FI': 'EUR', // Finland
    'EE': 'EUR', // Estonia
    'LV': 'EUR', // Latvia
    'LT': 'EUR', // Lithuania
    'SK': 'EUR', // Slovakia
    'SI': 'EUR', // Slovenia
    'HR': 'EUR', // Croatia
    'PL': 'PLN', // Poland
    'CZ': 'CZK', // Czech Republic
    'HU': 'HUF', // Hungary
    'RO': 'RON', // Romania
    'BG': 'BGN', // Bulgaria
    'SE': 'SEK', // Sweden
    'DK': 'DKK', // Denmark
    'NO': 'NOK', // Norway
    'IS': 'ISK', // Iceland
    'TR': 'TRY', // Turkey
    'RU': 'RUB', // Russia
    'UA': 'UAH', // Ukraine
    'BY': 'BYN', // Belarus
    'MD': 'MDL', // Moldova
    'RS': 'RSD', // Serbia
    'BA': 'BAM', // Bosnia and Herzegovina
    'ME': 'EUR', // Montenegro
    'MK': 'MKD', // North Macedonia
    'AL': 'ALL', // Albania
    'XK': 'EUR', // Kosovo
    'GE': 'GEL', // Georgia
    'AM': 'AMD', // Armenia
    'AZ': 'AZN', // Azerbaijan

    // Asia
    'CN': 'CNY', // China
    'JP': 'JPY', // Japan
    'KR': 'KRW', // South Korea
    'IN': 'INR', // India
    'PK': 'PKR', // Pakistan
    'BD': 'BDT', // Bangladesh
    'LK': 'LKR', // Sri Lanka
    'NP': 'NPR', // Nepal
    'BT': 'BTN', // Bhutan
    'MV': 'MVR', // Maldives
    'ID': 'IDR', // Indonesia
    'MY': 'MYR', // Malaysia
    'TH': 'THB', // Thailand
    'VN': 'VND', // Vietnam
    'PH': 'PHP', // Philippines
    'SG': 'SGD', // Singapore
    'BN': 'BND', // Brunei
    'KH': 'KHR', // Cambodia
    'LA': 'LAK', // Laos
    'MM': 'MMK', // Myanmar
    'TL': 'USD', // Timor-Leste
    'MN': 'MNT', // Mongolia
    'KZ': 'KZT', // Kazakhstan
    'UZ': 'UZS', // Uzbekistan
    'TM': 'TMT', // Turkmenistan
    'KG': 'KGS', // Kyrgyzstan
    'TJ': 'TJS', // Tajikistan
    'AF': 'AFN', // Afghanistan
    'IR': 'IRR', // Iran
    'IQ': 'IQD', // Iraq
    'SY': 'SYP', // Syria
    'JO': 'JOD', // Jordan
    'LB': 'LBP', // Lebanon
    'IL': 'ILS', // Israel
    'PS': 'ILS', // Palestine
    'SA': 'SAR', // Saudi Arabia
    'AE': 'AED', // United Arab Emirates
    'QA': 'QAR', // Qatar
    'BH': 'BHD', // Bahrain
    'KW': 'KWD', // Kuwait
    'OM': 'OMR', // Oman
    'YE': 'YER', // Yemen
    'TW': 'TWD', // Taiwan
    'HK': 'HKD', // Hong Kong
    'MO': 'MOP', // Macau

    // Africa
    'ZA': 'ZAR', // South Africa
    'EG': 'EGP', // Egypt
    'NG': 'NGN', // Nigeria
    'KE': 'KES', // Kenya
    'GH': 'GHS', // Ghana
    'ET': 'ETB', // Ethiopia
    'TZ': 'TZS', // Tanzania
    'UG': 'UGX', // Uganda
    'MA': 'MAD', // Morocco
    'DZ': 'DZD', // Algeria
    'TN': 'TND', // Tunisia
    'LY': 'LYD', // Libya
    'SD': 'SDG', // Sudan
    'SS': 'SSP', // South Sudan
    'AO': 'AOA', // Angola
    'MZ': 'MZN', // Mozambique
    'ZM': 'ZMW', // Zambia
    'ZW': 'ZWL', // Zimbabwe
    'BW': 'BWP', // Botswana
    'NA': 'NAD', // Namibia
    'SZ': 'SZL', // Eswatini
    'LS': 'LSL', // Lesotho
    'MG': 'MGA', // Madagascar
    'MU': 'MUR', // Mauritius
    'SC': 'SCR', // Seychelles
    'RE': 'EUR', // Réunion
    'YT': 'EUR', // Mayotte
    'KM': 'KMF', // Comoros
    'CM': 'XAF', // Cameroon
    'CI': 'XOF', // Ivory Coast
    'SN': 'XOF', // Senegal
    'ML': 'XOF', // Mali
    'BF': 'XOF', // Burkina Faso
    'NE': 'XOF', // Niger
    'TD': 'XAF', // Chad
    'CF': 'XAF', // Central African Republic
    'CG': 'XAF', // Republic of the Congo
    'CD': 'CDF', // DR Congo
    'GA': 'XAF', // Gabon
    'GQ': 'XAF', // Equatorial Guinea
    'ST': 'STN', // São Tomé and Príncipe
    'RW': 'RWF', // Rwanda
    'BI': 'BIF', // Burundi
    'SO': 'SOS', // Somalia
    'DJ': 'DJF', // Djibouti
    'ER': 'ERN', // Eritrea
    'GM': 'GMD', // Gambia
    'GN': 'GNF', // Guinea
    'GW': 'XOF', // Guinea-Bissau
    'SL': 'SLL', // Sierra Leone
    'LR': 'LRD', // Liberia
    'TG': 'XOF', // Togo
    'BJ': 'XOF', // Benin
    'MR': 'MRU', // Mauritania
    'CV': 'CVE', // Cape Verde
    'MW': 'MWK', // Malawi

    // Oceania
    'AU': 'AUD', // Australia
    'NZ': 'NZD', // New Zealand
    'FJ': 'FJD', // Fiji
    'PG': 'PGK', // Papua New Guinea
    'NC': 'XPF', // New Caledonia
    'PF': 'XPF', // French Polynesia
    'SB': 'SBD', // Solomon Islands
    'VU': 'VUV', // Vanuatu
    'WS': 'WST', // Samoa
    'TO': 'TOP', // Tonga
    'KI': 'AUD', // Kiribati
    'TV': 'AUD', // Tuvalu
    'NR': 'AUD', // Nauru
    'PW': 'USD', // Palau
    'FM': 'USD', // Micronesia
    'MH': 'USD', // Marshall Islands
    'GU': 'USD', // Guam
    'MP': 'USD', // Northern Mariana Islands
    'AS': 'USD', // American Samoa
    'CK': 'NZD', // Cook Islands
    'NU': 'NZD', // Niue
    'TK': 'NZD', // Tokelau
    'PN': 'NZD', // Pitcairn Islands
    'WF': 'XPF', // Wallis and Futuna

    // Caribbean & Other Territories
    'PR': 'USD', // Puerto Rico
    'VI': 'USD', // US Virgin Islands
    'VG': 'USD', // British Virgin Islands
    'KY': 'KYD', // Cayman Islands
    'BM': 'BMD', // Bermuda
    'TC': 'USD', // Turks and Caicos
    'AI': 'XCD', // Anguilla
    'MS': 'XCD', // Montserrat
    'MF': 'EUR', // Saint Martin
    'SX': 'ANG', // Sint Maarten
    'CW': 'ANG', // Curaçao
    'AW': 'AWG', // Aruba
    'BQ': 'USD', // Caribbean Netherlands
    'FK': 'FKP', // Falkland Islands
    'GI': 'GIP', // Gibraltar
    'GG': 'GBP', // Guernsey
    'JE': 'GBP', // Jersey
    'IM': 'GBP', // Isle of Man
    'FO': 'DKK', // Faroe Islands
    'GL': 'DKK', // Greenland
    'SJ': 'NOK', // Svalbard
    'AX': 'EUR', // Åland Islands
    'PM': 'EUR', // Saint Pierre and Miquelon
    'BL': 'EUR', // Saint Barthélemy
    'MQ': 'EUR', // Martinique
    'GP': 'EUR', // Guadeloupe
    'HM': 'AUD', // Heard Island and McDonald Islands
    'NF': 'AUD', // Norfolk Island
    'CX': 'AUD', // Christmas Island
    'CC': 'AUD', // Cocos Islands
    'TF': 'EUR', // French Southern Territories
    'IO': 'USD', // British Indian Ocean Territory
    'SH': 'SHP', // Saint Helena
    'GS': 'GBP', // South Georgia
    'AQ': 'USD', // Antarctica
    'BV': 'NOK', // Bouvet Island
    'UM': 'USD', // US Minor Outlying Islands
  };

  /// Country names for display purposes
  static const Map<String, String> _countryNames = {
    'US': 'United States',
    'CA': 'Canada',
    'GB': 'United Kingdom',
    'TR': 'Turkey',
    'DE': 'Germany',
    'FR': 'France',
    'IT': 'Italy',
    'ES': 'Spain',
    'AU': 'Australia',
    'NZ': 'New Zealand',
    'JP': 'Japan',
    'CN': 'China',
    'KR': 'South Korea',
    'IN': 'India',
    'BR': 'Brazil',
    'MX': 'Mexico',
    'AR': 'Argentina',
    'RU': 'Russia',
    'SA': 'Saudi Arabia',
    'AE': 'United Arab Emirates',
    'ZA': 'South Africa',
    'EG': 'Egypt',
    'NG': 'Nigeria',
    'SG': 'Singapore',
    'MY': 'Malaysia',
    'TH': 'Thailand',
    'ID': 'Indonesia',
    'PH': 'Philippines',
    'VN': 'Vietnam',
    'PK': 'Pakistan',
    'BD': 'Bangladesh',
    'PL': 'Poland',
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'SE': 'Sweden',
    'NO': 'Norway',
    'DK': 'Denmark',
    'FI': 'Finland',
    'CH': 'Switzerland',
    'AT': 'Austria',
    'GR': 'Greece',
    'PT': 'Portugal',
    'CZ': 'Czech Republic',
    'HU': 'Hungary',
    'RO': 'Romania',
    'UA': 'Ukraine',
    'IL': 'Israel',
    'IE': 'Ireland',
    'CL': 'Chile',
    'CO': 'Colombia',
    'PE': 'Peru',
    'VE': 'Venezuela',
    'KE': 'Kenya',
    'GH': 'Ghana',
    'ET': 'Ethiopia',
    'MA': 'Morocco',
    'DZ': 'Algeria',
    'TN': 'Tunisia',
  };
}

