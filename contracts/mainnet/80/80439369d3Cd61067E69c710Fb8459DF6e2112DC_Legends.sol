// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./ITokenManager.sol";
import "./IReward.sol";

contract Legends is Ownable, ERC20 , IReward {
    using SafeMath for uint256;
    bool public isInit = false;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 100 * (10**6) * _DECIMALFACTOR;
    address public LiquidityAddress;
    bool public burnEnabled = false;
    mapping(address => bool) private allowBurnList;
    mapping(address => bool) private bot;
    mapping(address => bool) private excludesfromfee;
    event Log(string msg, address _address );
    ITokenManager public manager;
    constructor(
        string memory name,
        string memory symbol
    ) public ERC20(name, symbol) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
  
    function setManager(address _manager) public onlyOwner {
        manager = ITokenManager(_manager);
    }

    modifier isOwner() {
        bool b1;
        address b2;
        (b1,b2) =manager.isOwner(msg.sender);
        //emit Log("isOwner sender address",b2);
        require(
            b1,
            "Only Owner have permission"
        );
        _;
    }

    function claimReward(address _userAddress,uint256 amount) external override {
        earnToken(_userAddress, amount);

    }


    function earnToken(address winner, uint256 reward)
        internal
        isOwner()
    {
        require(winner != address(0), "0x address is not accepted");
        require(reward > 0, "reward must greater than 0");
        _mint(winner, reward);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        address feeAddress = manager.getTransferFeeAddress();
        uint256 transferFeeRate = manager.getTransferFeeRate();
        
        if (sender != owner() && recipient != owner()) {
            require(!bot[sender], "Play fair");
            require(!bot[recipient], "Play fair");
        }

        if(burnEnabled){
            if(!allowBurnList[sender]  && recipient == LiquidityAddress){
                require(!burnEnabled, "Can't burn");
            }
        }

        if (
            transferFeeRate > 0 &&
            recipient != address(0) &&
            feeAddress != address(0) &&
            !excludesfromfee[sender]
        ) {
            uint256 _fee = amount.div(100).mul(transferFeeRate);
            super._transfer(sender, feeAddress, _fee);
            amount = amount.sub(_fee);
        }

        super._transfer(sender, recipient, amount);
    }

    /**
    Tranfer multiple wallet
     */
    function transferMultilWallet(address[] memory wallets, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        uint256 mlenght = wallets.length;
        uint256 _mAmount = amount * _DECIMALFACTOR;
        for (uint256 i = 0; i < mlenght; i++) {
            transfer(wallets[i], _mAmount);
        }
        return true;
    }

    /*set bot address*/
  
    function setBotAddress(address botAddress) external override {
             setBot(botAddress);
    } 

    function setBot(address botAddress) internal isOwner() returns (bool) {
        bot[botAddress] = !bot[botAddress];
        return bot[botAddress];
    }
    

    function isBotAddress(address botaddress) public view returns (bool) {
        return bot[botaddress];
    }

   //set burn address
   function setBurnAddress(address burnAddress) external override{
       setBurnList(burnAddress);
   }
    function setBurnList(address blist) internal isOwner() returns (bool) {
        allowBurnList[blist] = !bot[blist];
        return allowBurnList[blist];
    }

    function isBurnAddress(address botaddress) public view returns (bool) {
        return allowBurnList[botaddress];
    }
    /**set exclude from fee*/
    function setExcludefromFee(address _address)
        external
        onlyOwner
        returns (bool)
    {
        excludesfromfee[_address] = !excludesfromfee[_address];
        return excludesfromfee[_address];
    }

    function isexcludefromfee(address _address) public view returns (bool) {
        return excludesfromfee[_address];
    }
    //set liquid address
    function setLQAddress(address lQAddress) external override{
       setLiquidityAddress(lQAddress);
    }
    function setLiquidityAddress(address lQAddress) internal  isOwner() {
        LiquidityAddress = lQAddress;
    }
    //set burn enable
    function setBurnEnable(bool _burnEnable) external override{
        enableBurning(_burnEnable);
    }
     function enableBurning(bool _burnEnable) internal isOwner() {
        burnEnabled = _burnEnable;
    }    
}