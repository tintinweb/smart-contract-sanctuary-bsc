// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./SafeMathUpgradeable.sol";
import "./Initializable.sol";
import "./AccessControlEnumerableUpgradeable.sol";
import "./IERC721Upgradeable.sol";
import "./IERC20Upgradeable.sol";
                                                                                                    
/**
                        _                           _           _       
                       | |                         | |         (_)      
   ___ _ __ _   _ _ __ | |_ ___  ___  ___ _ __   __| | ___ _ __ _  ___  
  / __| '__| | | | '_ \| __/ _ \/ __|/ _ \ '_ \ / _` |/ _ \ '__| |/ _ \ 
 | (__| |  | |_| | |_) | || (_) \__ \  __/ | | | (_| |  __/ |_ | | (_) |
  \___|_|   \__, | .__/ \__\___/|___/\___|_| |_|\__,_|\___|_(_)|_|\___/ 
             __/ | |                                                    
            |___/|_|             

 https://cryptosender.io

 Send tokens to multiple addresses at once with a reduced  
*/
contract Cryptosender is ContextUpgradeable, AccessControlEnumerableUpgradeable {    
    struct VipLevel{
        uint256 level;        
        uint256 fee;
        uint256 price;
        uint256 vipTime;
    }
    // Relation between user address and purchased vip level
    mapping(address => uint256)  _purchasedVipLevel;
    // Relation between user address and purchased vip level date
    mapping(address => uint256)  _purchasedOn;    
    // Vip level settings
    mapping(uint256 => VipLevel) _vipLevels;
    // Team wallet ( developer )
    address team;
    function initialize() public initializer { 
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        team = _msgSender();
        addVipLevel(0, 0.25 ether, 0 ether, 0 days);
        addVipLevel(1, 0 ether, 1 ether, 1 days);
        addVipLevel(2, 0 ether, 3 ether, 7 days);
        addVipLevel(3, 0 ether, 5 ether, 30 days);
        addVipLevel(4, 0 ether, 10 ether, 90 days);
    }

    /**
     * Add new vip level to the system. 
     * This is used on creation of contract to configure the vip levels of system.
     */
    function addVipLevel(uint256 level, uint256 fee, uint256 price, uint256 vipTime) internal {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _vipLevels[level] = VipLevel(level, fee, price, vipTime);
    }
    /**
     * Utility method to sum array of uints     
     */
    function _sumAmounts(uint256[] memory amounts) internal pure returns(uint256){
        uint sum = 0;
        uint length = amounts.length;
        for(uint i = 0; i < length; i++){
            sum += amounts[i];
        }
        return sum;
    }

    /**
     * Returns the current purchased vip level of user
     */
    function currentLevel(address user) public view returns(VipLevel memory){
        uint256 _pOn     = _purchasedOn[user];
        uint256 _endDate = _pOn + _vipLevels[_purchasedVipLevel[user]].vipTime;
        if(block.timestamp > _endDate){
            return _vipLevels[0];
        }
        return _vipLevels[_purchasedVipLevel[user]];
    }

    /**
     * Process a purchase vip level
     */
    function purchaseVip(uint256 level) public payable {
        VipLevel memory vipLevel = _vipLevels[level];   
        require(_vipLevels[level].price > 0);     
        require(_purchasedVipLevel[msg.sender] < level);
        require(msg.value >= vipLevel.price, "Insufficient balance");
        _purchasedVipLevel[msg.sender] = level;
        _purchasedOn[msg.sender] = block.timestamp;        
        _sendEther(team, msg.value);
    }

    /**
     * Distribute ERC-20 tokens
     */
    function distribute(
        address token,
        address[] memory destiny, 
        uint256[] memory amounts
    ) public payable{        
        uint256 _fee      = currentLevel(msg.sender).fee;        
        _checkDistribution(_fee, destiny.length, amounts.length);
        uint length = destiny.length;
        for(uint i = 0; i < length; i++){            
            IERC20Upgradeable(token).transferFrom(msg.sender, destiny[i], amounts[i]);
        }        
        _sendEther(team, _fee);
    }

    /**
     * Distribute Native chain tokens
     */
    function distributeEther(
        address[] memory destiny, 
        uint256[] memory amounts
    ) public payable{        
        uint256 _fee      = currentLevel(msg.sender).fee;        
        _checkDistribution(_fee + _sumAmounts(amounts), destiny.length, amounts.length);
        uint length = destiny.length;
        for(uint i = 0; i < length; i++){
            _sendEther(destiny[i], amounts[i]);
        }        
        _sendEther(team, _fee);
    }

    /**
     * Returns the current fee of user
     */
    function distributionFee(address from) public view returns(uint256){
        return _vipLevels[_purchasedVipLevel[from]].fee;
    }
    /**
     * Returns vip price of level
     */
    function vipPrice(uint256 level) public view returns(uint256){
        return _vipLevels[level].price;
    }
    /**
     * Assertions for fistribution
     */
    function _checkDistribution(
        uint256 _fee, 
        uint256 _destiny, 
        uint256 _amounts        
    ) internal{        
        require(_destiny == _amounts, "invalid lengths");        
        require(msg.value >= _fee, "insufficient fee");            
    }
    /**
     * Utility method for send native chain token
     */
    function _sendEther(address to, uint256 amount) internal {
        (bool sended,) = payable(to).call{value: amount}("");
        require(sended == true);
    }
    function getURL() public pure returns(string memory){
        return "https://cryptosender.io";
    }
}