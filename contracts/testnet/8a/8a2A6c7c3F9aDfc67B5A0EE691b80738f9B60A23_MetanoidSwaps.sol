/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity 0.8.0; 
 
interface IOwnable {
    function manager() external view returns (address);
 
    function renounceManagement() external;
 
    function pushManagement(address newOwner_) external;
 
    function pullManagement() external;
}
 
contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;
 
    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);
 
    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }
 
    function manager() public view override returns (address) {
        return _owner;
    }
 
    modifier onlyManager() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
 
    function renounceManagement() public virtual override onlyManager {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }
 
    function pushManagement(address newOwner_) public virtual override onlyManager {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }
 
    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}
 
interface IERC20 {
    function decimals() external view returns (uint8);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function totalSupply() external view returns (uint256);
 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract MetanoidSwaps is Ownable{
 
    uint256 public rate;
    IERC20 token;
 
 
        constructor(address meta){
                token = IERC20(meta);
        }
 
         function amountForInGame(uint256 value) public view returns(uint256){ // returns when you swap ingame to meta
             return value / rate;
 
        }
 
          function amountForMeta(uint256 value) public view returns(uint256){ // returns when you swap meta for ingame
              return value * rate;
 
        }
 
        function swapMeta(uint256 value) public {
                require(token.transferFrom(msg.sender, address(this), value), "Unable to proceed to the transfer");
 
        }
 
        function swapInGame(uint256 value) public {
                require(token.transfer(msg.sender, amountForInGame(value)));
        }
 
        function recoverLostToken(address _token) onlyManager external returns (bool) {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
        return true;
         }
 
 
             function getRate() public view returns(uint256){
              return rate;
           }
 
          function setRate(uint256 _rate) public returns(uint256){
                rate = _rate;
            }
 
 
 
}