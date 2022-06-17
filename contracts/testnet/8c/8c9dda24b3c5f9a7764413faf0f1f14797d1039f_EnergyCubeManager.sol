/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

pragma solidity^0.8.0;

contract SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

interface IEnergyQube{
    function mint(address _to, uint _id, uint _amount) external;
    function getMaxMintedId() external view returns (uint256);
    function addEfficiency(uint256 id, uint256 amount) external;
    function addCapacity(uint256 id, uint256 amount) external;
    function addCharge(uint256 id, uint256 amount) external;
}

interface IWQWS{
    function buyECforWQC(address player, uint256 wqc_amount) external;
    function sellECforWQC(address player, uint256 EC_id) external;
    function mintFee(address player, uint256 wqc_amount) external;
    function improveECforWQC(address player, uint256 EC_id, uint256 wqc_amount) external;
}

interface IWQC{
    function burn(uint256 amount) external returns (bool);
}

contract EnergyCubeManager is SafeMath {
    address private EnergyCube_address;
    address private WQWS_address;
    address private WQC_address;
    string private _name;
    string private _symbol;
    address private contractOwner;

    uint256 public X;
    uint256 public Y;
    uint256 public Z;
    uint256 public K;
    uint256 public N;

    uint256 public maxEfficiency = 200;
    uint256 public maxCapacity = 200;

    IEnergyQube EnergyQubeContract = IEnergyQube(EnergyCube_address);
    IWQWS WQWSContract = IWQWS(WQWS_address);
    IWQC WQCContract = IWQC(WQC_address);

    constructor(
      string memory contractName,
      string memory contractSymbol,
      address energyCubeAddress,
      address WQWSAddress,
      address WQCAddress
  ) public {
    contractOwner = msg.sender;
    _name = contractName;
    _symbol = contractSymbol;
    EnergyCube_address = energyCubeAddress;
    WQWS_address = WQWSAddress;
    WQC_address = WQCAddress;
  }

  function setX(uint256 x) public {
     X = x;
  }

  function setY(uint256 y) public {
     Y = y;
  }

  function setN(uint256 n) public {
     N = n;
  }

  function setZ(uint256 z) public {
     Z = z;
  }

  function setK(uint256 k) public {
     K = k;
  }

  function buyEnergyCube(address player, uint256 amount, uint256 WQCAmount) public {
      WQWSContract.buyECforWQC(player, WQCAmount);
      uint256 maxMintedId = EnergyQubeContract.getMaxMintedId();
      EnergyQubeContract.mint(player, maxMintedId+1, amount);
      WQCContract.burn(mul(WQCAmount, X));
      //ADD INTERACTION W/ WQ Market Contract
  }

  function sellEnergyCube(address player, uint256 EC_id) public {
      //TO CLARIFY SELLING SCHEME
  }

  function mintEnergyCube(address player, uint256 amount, uint256 WQCAmount) public {
      uint256 maxMintedId = EnergyQubeContract.getMaxMintedId();
      EnergyQubeContract.mint(player, maxMintedId+1, amount);
      //TO CLARIFY MINT COMBINATION AVAL
      WQWSContract.mintFee(player, WQCAmount);
      WQCContract.burn(mul(WQCAmount, Y));
  }
  
  function addEffEnergyCube(address player, uint256 EC_id, uint256 WQCAmount, uint256 energyAmount) public {
      WQWSContract.improveECforWQC(player, EC_id, WQCAmount);
      EnergyQubeContract.addEfficiency(EC_id, energyAmount);
      WQCContract.burn(mul(WQCAmount,Z));
  }

  function addCapEnergyCube(address player, uint256 EC_id, uint256 WQCAmount, uint256 capAmount) public {
      WQWSContract.improveECforWQC(player, EC_id, WQCAmount);
      EnergyQubeContract.addCapacity(EC_id, capAmount);
      WQCContract.burn(mul(WQCAmount,Z));
  }

  function addChargeEnergyCube(address player, uint256 EC_id, uint256 WQCAmount, uint256 capAmount) public {
      WQWSContract.improveECforWQC(player, EC_id, WQCAmount);
      EnergyQubeContract.addCharge(EC_id, capAmount);
  }
}