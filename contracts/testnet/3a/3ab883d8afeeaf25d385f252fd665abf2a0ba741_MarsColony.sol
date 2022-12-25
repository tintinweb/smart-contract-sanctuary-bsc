/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./IERC20.sol";

contract MarsColony {

  struct User {
    uint256 spin;
    uint256 parcelCount;
    uint256 dailySpin;
    uint256 dateLastClaim;
    address ref;
    Parcel[] parcels;
  }


  struct Parcel {
    uint x; // Coordonnée x de la parcelle
    uint y; // Coordonnée y de la parcelle
    uint level; // Niveau de la parcelle
    uint spinPerDay; // Nombre de spin gagnés par jour par la parcelle
    bool upgrading; //en cours d'upgrade
    uint256 upgradeActivationTime; //date de fin de l'upgrade en cours
    address owner; // Propriétaire de la parcelle
  }

  mapping(uint => mapping(uint => Parcel)) public parcels;
  mapping(address => User) public users;


  // IERC20 constant BUSD_TOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
  IERC20 constant BUSD_TOKEN = IERC20(0x296B616318aeb80697AC64fbc5546a96b1608572); // for testing
  
  address feeWallet;
  uint256 totalPlayers;

  uint[] public parcelPricesUpdate = [100, 200, 300];
  uint public parcelPrice = 30;
  uint[] public yieldParcel = [100, 200, 300];
  uint[] public upgradeDuration = [1 minutes, 2 minutes , 3 minutes];
  uint256 public spinPerDayForParcel0 = 1;
  
  uint feePercentage = 5;
  uint256 spinConvertor = 1e18; // 1 busd = 1 spin


  constructor(address _feeWallet) public {
    feeWallet = _feeWallet;
  }

  // Fonction pour acheter des spin
  function buySpin(uint amount) public {
    uint256 spin = amount / spinConvertor;
    uint256 fee = amount * feePercentage / 100;


    BUSD_TOKEN.transferFrom(msg.sender, feeWallet, fee);
    BUSD_TOKEN.transferFrom(msg.sender, address(this), amount - fee);


    // Mettre à jour les informations de l'utilisateur
    User storage user = users[msg.sender];
    user.spin += spin;

  }


  // Fonction pour acheter une parcelle de terrain
  function buyParcel(uint x, uint y) public {
    require(x < 50 && y < 100, "Invalid coordinates");
    require(parcels[x][y].owner == address(0), "Parcel already bought");


    parcels[x][y] = Parcel(x, y, 0, spinPerDayForParcel0, false, 0, msg.sender);

    // Mettre à jour les informations de l'utilisateur
    User storage user = users[msg.sender];
    user.spin -= parcelPrice;
    user.parcelCount++;
    user.parcels.push(parcels[x][y]);
    user.dailySpin += yieldParcel[parcels[x][y].level];

  }


  function upgradeParcel(uint x, uint y) public {
    // Récupérer la parcelle
    Parcel storage parcel = parcels[x][y];
    require(parcel.owner == msg.sender, "Not the owner of the parcel");
    require(parcel.upgrading == false, "already being upgrade");
    require(parcel.level < 3, "already max update");

    // Calculer le coût de l'amélioration
    uint cost = parcelPricesUpdate[parcel.level];
    require(users[msg.sender].spin >= cost, "Not enough spin");

    // Mettre à jour les informations de l'utilisateur
    User storage user = users[msg.sender];
    user.spin -= cost;

    // Marquer la parcelle comme en cours d'amélioration
    parcel.upgrading = true;
    parcel.upgradeActivationTime = block.timestamp + upgradeDuration[parcel.level];

  }


  function activateUpgradeParcel(uint x, uint y) public {
    // Récupérer la parcelle
    Parcel storage parcel = parcels[x][y];
    require(parcel.owner == msg.sender, "Not the owner of the parcel");
    require(parcel.upgradeActivationTime > block.timestamp , "Too early to activate");
    require(parcel.upgrading == true , "You did not upgrade this parcel");

    // On claim avant
    getSpin(msg.sender);

    // Marquer la parcelle comme n'étant plus en cours d'upgrade et upgrade
    parcel.upgrading = false;
    parcel.upgradeActivationTime = 0;
    parcel.level += 1;

    // Augmenter le niveau de la parcel et ajouter du yield
    User storage user = users[msg.sender];
    user.dailySpin += yieldParcel[parcel.level];

  }


  function claimSpin() public{
    getSpin(msg.sender);
  }

  function getSpin(address _user) internal {
    User storage user = users[_user];
    require(user.dateLastClaim > 0, "User is not registered");

    if (user.dailySpin > 0) {
        uint256 hrs = block.timestamp / 3600 - user.dateLastClaim / 3600;
        hrs = hrs > 24 ? 24 : hrs;
        user.spin += hrs * user.dailySpin;
    }
    user.dateLastClaim = block.timestamp;  
  }



  function getUser(address _userAddress) public view returns (User memory) {
    return users[_userAddress];
  }
}