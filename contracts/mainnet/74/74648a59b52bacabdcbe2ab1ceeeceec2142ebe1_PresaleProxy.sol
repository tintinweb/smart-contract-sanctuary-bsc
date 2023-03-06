/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at testnet.snowtrace.io on 2023-02-14
*/

pragma solidity ^0.6.12;

pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT
interface IDeployerUpgradeable{
        function deployProxy(address[] calldata _addresses,uint256[] calldata _values,bool[] memory _isSet,string[] memory _details) external returns (address);

}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
     function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}


library SafeMathUpgradeable {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

contract PresaleProxy is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    struct Sale{
        address _sale;
        uint256 _start;
        uint256 _end;
        string _name;
        address _usewithToken;
        bool _launchpadType;
        bool _isWhitelisted;
    }

    uint256 public depolymentFee;
    uint256 public fee ;
    uint256 public userFee ;
    bool public checkForSuccess;  // Make False to Sale reaches soft cap to make it success

    address public fundReciever;

    address public implementation;
   

    mapping(address => address) public _preSale;
    mapping(address => uint256) public saleId;
    Sale[] public _sales;

    // constructor() public{

    // }


    function initialize() public initializer {
        __Ownable_init();
        checkForSuccess = true;
        depolymentFee = 0;
        fee = 0 ;
        userFee = 0 ;
    }


    function setImplemnetation(address _implemetation) public onlyOwner{
        implementation = _implemetation;
    }
 

    function getSale(address _token) public view returns (address) {
        return _preSale[_token];
    }

    function setDeploymentFee(uint256 _fee) external onlyOwner {
        depolymentFee = _fee;
    }

    function setForSuccess(bool _value) external onlyOwner {
       checkForSuccess = _value;
    }

    function setTokenFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }


    function getDeploymentFee() public view returns(uint256){
        return depolymentFee;
    }
 

    function setUserFee(uint256 _userfee) external onlyOwner {
        userFee = _userfee;
    }

    function getUserFee() public view returns(uint256){
        return userFee;
    } 
    function getfundReciever() public view returns (address){
        return fundReciever;
    }

    function setfundReciever(address _reciever) external onlyOwner {
        fundReciever = _reciever;
    }

    function getTokenFee() public view returns(uint256){
        return fee;
    }

    function getTotalSales() public view returns (Sale[] memory){
        return _sales;
    }

    function getCheckSuccess() public view returns (bool){
        return checkForSuccess;
    }


    function deleteSalePresale(address _saleAddress) public onlyOwner {
        uint256 _saleId = saleId[_saleAddress];
        _sales[_saleId] = _sales[_sales.length - 1];
        saleId[_sales[_sales.length - 1]._sale] = _saleId;
        _sales.pop();
    }

    function createPresale(address[] calldata _addresses,uint256[] calldata _values,bool[] memory _isSet,string[] memory _details) public payable {
          // _token 0
        //_router 1
        //owner 2
        // usewithToken 3 i.e buytoken 3
        
        //_min 0 
        //_max 1
        //_rate 2
        // _soft  3
        // _hard 4
        //_pancakeRate  5
        //_unlockon  6
        // _percent 7
        // _start 8
        //_end 9
        //_vestPercent 10
        //_vestInterval 11
        //_userFee 12

        // isAuto 0
        //_isvested 1
        // isWithoutToken 2
        // isWhitelisted 3
        // buyType isBNB or not 4
        // isToken isToken or not 5
        // LaunchpadType normal or fair 6

        // description 0 
        // website,twitter,telegram 1,2,3
        // logo 4
        // name 5
        // symbol 6
        // githup 7
        // instagram 8
        // discord 9
        // reddit 10
        // youtube 11

           require(depolymentFee == msg.value,"Insufficient fee");
           payable(fundReciever).transfer(msg.value);
         address _saleAddress = IDeployerUpgradeable(implementation).deployProxy(_addresses,_values,_isSet,_details);
           _preSale[_addresses[0]] = _saleAddress;
           saleId[_saleAddress] = _sales.length;
            _sales.push(
                Sale({
                    _sale: _saleAddress,
                    _start: _values[8],
                    _end: _values[9],
                    _name: _details[5],
                    _usewithToken : _addresses[3],
                    _launchpadType : _isSet[6],
                    _isWhitelisted : _isSet[3]

                })
            );
        
        
    }


}