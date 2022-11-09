import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'fiat_state.dart';

class FiatCubit extends Cubit<FiatState> {
  FiatCubit() : super(FiatState());
  DfxRequests dfxRequests = DfxRequests();
  LockHelper lockHelper = LockHelper();
  EncryptHelper encryptHelper = EncryptHelper();

  addContacts(
    String email,
    String phone,
  ) {
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: phone,
      email: email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      isShowTutorial: state.isShowTutorial,
      personalInfo: state.personalInfo,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  createUser(String email, String phone, String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      personalInfo: state.personalInfo,
    ));
    await dfxRequests.createUser(
      email,
      phone,
      accessToken,
    );
    addContacts(email, phone);
  }

  changeStatusTutorial(bool status) async {
    var box = await Hive.openBox(HiveBoxes.client);
    String tutorialStatus = !status ? 'skip' : 'show';
    await box.put(HiveNames.tutorialStatus, tutorialStatus);
    await box.close();

    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      isShowTutorial: status,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  addIban(String iban) {
    List<String>? ibanList;
    if (state.ibansList != null) {
      ibanList = state.ibansList!;
      ibanList.add(iban);
    } else {
      ibanList = [iban];
    }

    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: iban,
      ibansList: ibanList,
      activeIban: state.activeIban,
      ibanList: state.ibanList,
      assets: state.assets,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  changeCurrentIban(IbanModel iban) => emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: iban.iban,
        ibansList: state.ibansList,
        assets: state.assets,
        activeIban: iban,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));

  loadUserDetails(AccountModel account, ECPair keyPair) async {
    var box = await Hive.openBox(HiveBoxes.client);
    String? tutorialStatus = await box.get(HiveNames.tutorialStatus);
    bool isShowTutorial;
    if (tutorialStatus == null) {
      isShowTutorial = state.isShowTutorial!;
    } else {
      isShowTutorial = tutorialStatus == 'show';
    }

    await box.close();
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      isShowTutorial: isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));

    try {
      String accessToken = state.accessToken ?? await getAccessToken(account, keyPair);
      Map<String, dynamic> data = await dfxRequests.getUserDetails(accessToken);
      List<FiatHistoryModel> history = await dfxRequests.getHistory(accessToken);

      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: data['phone'],
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        kycHash: data['kycHash'],
        numberPrefix: state.numberPrefix,
        email: data['mail'],
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        isShowTutorial: isShowTutorial,
        accessToken: accessToken,
        isKycDataComplete: data['kycDataComplete'],
        limit: data['tradingLimit']['limit'],
        history: history,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        kycHash: state.kycHash,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        isShowTutorial: isShowTutorial,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  loadAvailableAssets() async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: state.personalInfo,
      countryList: state.countryList,
      fiatList: state.fiatList,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    try {
      List<AssetByFiatModel> assets =
      await dfxRequests.getAvailableAssets(state.accessToken!);
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: assets,
        foundAssets: assets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  saveBuyDetails(
      String iban, AssetByFiatModel asset, String accessToken) async {
    await dfxRequests.saveBuyDetails(iban, asset, accessToken);
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: iban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      activeIban: state.activeIban,
      ibanList: state.ibanList,
      isShowTutorial: state.isShowTutorial,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  loadIbanList({AssetByFiatModel? asset}) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      activeIban: state.activeIban,
      ibanList: state.ibanList,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    List<IbanModel> ibanList = await dfxRequests.getIbanList(state.accessToken!);
    List<IbanModel> activeIbanList =
        ibanList.where((el) => el.active!).toList();
    IbanModel? iban;

    try {
      if (state.currentIban != null && asset != null && state.currentIban != '') {
        iban = activeIbanList.firstWhere((element) =>
            element.asset!.name == asset.name &&
            element.iban == state.currentIban!.replaceAll(' ', ''));
      } else {
        iban = activeIbanList[0];
      }
    } catch (_) {
      iban = null;
    }

    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: '',
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      activeIban: iban,
      ibanList: activeIbanList,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  search(assets, value) {
    List<AssetByFiatModel> search = [];
    if (value == '') {
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: assets,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    } else {
      assets.forEach((element) {
        if (element.name.contains(value.toUpperCase())) {
          search.add(element);
        } else if (element.name
            .contains(value.replaceAll('d', '').toUpperCase())) {
          search.add(element);
        }
      });
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: search,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  loadCountryList() async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));

    try {
      List<dynamic> countryList = await dfxRequests.getCountryList(state.accessToken!);
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: countryList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  setUserName(String firstname, String surname) {
    Map? country;
    String? street;
    String? location;
    String? zip;
    if (state.personalInfo != null) {
      country = state.personalInfo!.country ?? null;
    }
    if (state.personalInfo != null) {
      street = state.personalInfo!.street ?? null;
    }
    if (state.personalInfo != null) {
      location = state.personalInfo!.location ?? null;
    }
    if (state.personalInfo != null) {
      zip = state.personalInfo!.zip ?? null;
    }
    KycModel kyc = KycModel(
      firstname: firstname,
      surname: surname,
      country: country,
      street: street,
      location: location,
      zip: zip,
    );
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: kyc,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  setCountry(Map country) {
    KycModel kyc = KycModel(
      firstname: state.personalInfo!.firstname,
      surname: state.personalInfo!.surname,
      country: country,
      street: state.personalInfo!.street ?? null,
      location: state.personalInfo!.location ?? null,
      zip: state.personalInfo!.zip ?? null,
    );
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: kyc,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  setAddress(
      String street, String city, String zipCode, String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: state.personalInfo,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    KycModel kyc = KycModel(
      firstname: state.personalInfo!.firstname,
      surname: state.personalInfo!.surname,
      country: state.personalInfo!.country,
      street: street,
      location: city,
      zip: zipCode,
    );
    await dfxRequests.saveKycData(kyc, accessToken);
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: kyc,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  loadFiatList(String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: state.personalInfo,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    List<FiatModel> fiatList = await dfxRequests.getFiatList(accessToken);
    List<FiatModel> activeFiatList =
        fiatList.where((el) => el.enable!).toList();
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: state.personalInfo,
      fiatList: activeFiatList,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
  }

  loadAllAssets({bool isSell = false}) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      activeIban: state.activeIban,
      ibanList: state.ibanList,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    try {
      List<FiatModel> fiatList = await dfxRequests.getFiatList(state.accessToken!);
      List<FiatModel> activeFiatList =
      fiatList.where((el) => el.enable!).toList();

      List<AssetByFiatModel> assets =
      await dfxRequests.getAvailableAssets(state.accessToken!);

      List<IbanModel> ibanList = await dfxRequests.getIbanList(state.accessToken!);
      List<IbanModel> activeIbanList =
      ibanList.where((el) => el.active!).toList();
      IbanModel? iban;

      try {
        if (state.currentIban != null && state.currentIban != '') {
          iban = activeIbanList
              .firstWhere((element) => (element.iban == state.currentIban!.replaceAll(' ', '')));
        } else {
          if (isSell) {
            iban = activeIbanList.firstWhere((element) => element.type == 'Sell');
          } else {
            iban = activeIbanList[0];
          }
        }
      } catch (_) {
        iban = null;
      }

      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        ibanList: activeIbanList,
        activeIban: iban,
        assets: assets,
        foundAssets: assets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: activeFiatList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        ibanList: state.ibanList,
        assets: state.assets,
        activeIban: state.activeIban,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  Future<void> loadCryptoRoute(AccountModel account, ECPair keyPair) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      accessToken: state.accessToken,
    ));
    try {
      String accessToken = state.accessToken ?? await getAccessToken(account, keyPair);
      Map<String, dynamic> data = await dfxRequests.getUserDetails(accessToken);

      CryptoRouteModel? route;
      if (data['kycDataComplete']) {
        route = await dfxRequests.getCryptoRoutes(accessToken);
        if (route == null) {
          route = await dfxRequests.createCryptoRoute(accessToken);
        }
      }
      emit(state.copyWith(
        status: FiatStatusList.success,
        cryptoRoute: route,
        accessToken: accessToken,
        kycHash: data['kycHash'],
        isKycDataComplete: data['kycDataComplete'],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        ibanList: state.ibanList,
        assets: state.assets,
        activeIban: state.activeIban,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
        cryptoRoute: state.cryptoRoute,
      ));
    }
  }

  Future<String> getAccessToken(AccountModel account, ECPair keyPair) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = await box.get(HiveNames.password);
    var password = stringToBase64.decode(encodedPassword);
    try {
      String accessToken = await dfxRequests.signIn(account, keyPair);
      return encryptHelper.getEncryptedData(accessToken, password);
    } catch (err) {
      throw err;
    }
  }
}
