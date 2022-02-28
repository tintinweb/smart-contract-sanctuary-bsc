/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
                                                                                                                                                       
                                 ++++++++        *****.        +****      =***    +++++++++++       *****=            ****      *****    =***          
                                 *@@@@@@@%       #@@@@%         @@@@%      @@#   #@@@@@@@@@@%       *@@@@@         #@@@@@@@@     @@@@#   :@@*          
                      *    *     *@@@%   -       @@@@@@=        %@@@@%     %@#   .  :@@@@:  +       %@@@@@*       #@@@#    -     :@@@@+  %@%           
                     +:    *     *@@@%          *@@#@@@%        %@@@@@@    %@#       @@@@          [email protected]@#@@@@       %@@@%           *@@@@.*@@            
                     =:    -=    *@@@%          @@* @@@@*       %@%@@@@@   %@#       @@@@          %@# %@@@#      *@@@@@%          %@@@@@@             
                    *-.    =:    *@@@@@@#      *@@  *@@@@       %@#=%@@@@  %@#       @@@@         [email protected]@  [email protected]@@@       [email protected]@@@@@@%        %@@@@*             
        *- *        *=.    +-=   *@@@%  +      @@%###@@@@*      %@#  %@@@@*%@#       @@@@         %@@###@@@@#         %@@@@@@       [email protected]@@@              
      #=   ###   %#=*=     +=+   *@@@%        *@@%%%%%@@@@      %@#   #@@@@@@#       @@@@        [email protected]@%%%%%@@@@           [email protected]@@@#      [email protected]@@%              
    ##+     #   :%#*#+---- *+    *@@@%        @@*     %@@@#     %@#    #@@@@@*       @@@@        %@#     %@@@%           #@@@#      [email protected]@@%              
    ##           #*#**+=---.+    *@@@%       *@@      [email protected]@@@     %@#     *@@@@*       @@@@       *@@      [email protected]@@@    %%*   *@@@%       [email protected]@@@              
   ##*            **==++==++     #@@@@      [email protected]@@      *@@@@%    @@@       *@@*      [email protected]@@@#      @@@      [email protected]@@@@   +%@@@@@@%.        #@@@@=             
   ##*           #***-=++--:                                                                                                                           
   ###+           +=+==+**                                                                                                                             
    %##       %#  =:-++**+                        %@@@@+        *@@@@@@@@%:      #@@@@@@@@     @@@@#      %@@        #@@@@%                            
     %%#     #%* .=..*+=+-:                       %@@@@@        [email protected]@@@*#@@@@#     [email protected]@@@***%     *@@@@%     *@%        #@@@@@                            
      #%#*   %%#*=*:+**+=--                      [email protected]@@@@@*       [email protected]@@@  [email protected]@@@     [email protected]@@@         *@@@@@%    *@%        @@%@@@%                           
        ####*%%#***+     *+                      @@*[email protected]@@@       [email protected]@@@  [email protected]@@%     [email protected]@@@         *@@@@@@%   *@%       #@%[email protected]@@@=                          
               %##                              *@%  %@@@#      [email protected]@@@  %@@%      [email protected]@@@%%%      *@@[email protected]@@@@  *@%       @@  *@@@%                          
               %%#                              @@#  #@@@@      [email protected]@@@%@@@*       [email protected]@@@##%      *@@  %@@@@+*@%      #@%  [email protected]@@@+                         
                ##*                            *@@@@@@@@@@#     [email protected]@@@*@@@@       [email protected]@@@         *@@   %@@@@%@%      @@@@@@@@@@@                         
                #                              @@*    [email protected]@@@     [email protected]@@@-#@@@@      [email protected]@@@         *@@    %@@@@@%     #@%     @@@@*                        
                %                             *@@      %@@@%    [email protected]@@@  %@@@%     [email protected]@@@     +   *@@     #@@@@%    [email protected]@:     *@@@@                        
                                              @@#      *@@@@=   [email protected]@@@   %@@@%    *@@@@@@@@@*   #@@      :%@@%    %@@      [email protected]@@@#                       
                                                                          #:                               *#                                          
                                                                                                                                                       

*/
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FantasyArenaPrivateSale {
    using SafeMath for uint256;
        
    IERC721 private fasyNft;
    IERC20 private fapToken;
    IERC20 private BUSD;
    
    address public owner;
    address public wallet;
    bool public enabled;
    bool public openToAll;

    uint256 public class1QualifyingNftCount;
    uint256 public class1FapPerBusd;
    uint256 public class2FapPerBusd;
    uint256 public class3FapPerBusd;

    uint256 public maxPurchase;
    uint256 public minPurchase;

    mapping (address => bool) public class1Whitelist;
    mapping (address => bool) public class2Whitelist;
    mapping (address => bool) public class3Whitelist;

    mapping (address => uint256) public purchased;
    mapping (address => bool) public noLimit;
    mapping (uint256 => bool) public class1QualifyingTokenIds;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "no permissions");
        _;
    }
    
    modifier onWhitelist() {
        require(
            fasyNft.balanceOf(msg.sender) > 0 || 
            class1Whitelist[msg.sender] || 
            class2Whitelist[msg.sender] || 
            class3Whitelist[msg.sender], 
            "this address is not on the whitelist");
        _;
    }
    
    modifier isEnabled() {
        require(enabled, "sale not enabled");
        _;
    }
    
    constructor() {
        fapToken = IERC20(0x88Bbcb56854fA496ebD0D906e3c36A03eA6a2770);
        fasyNft = IERC721(0x477113ef8BB9678618a3faA3CDAdc1eD4Df2b86c);
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        owner = msg.sender;
        wallet = 0x9eE18a3bBa5C48dCBAebef598d5519Db9Ce63eE7;

        class1FapPerBusd = 130;
        class2FapPerBusd = 125;
        class3FapPerBusd = 112;
        class1QualifyingNftCount = 3;

        maxPurchase = 200_000 * 10 ** 18;
        minPurchase = 100 * 10 ** 18;

        class1QualifyingTokenIds[59] = true;  // Fangs
        class1QualifyingTokenIds[121] = true; // Fangs
        class1QualifyingTokenIds[144] = true; // Fangs
        class1QualifyingTokenIds[113] = true; // Crystal
        class1QualifyingTokenIds[190] = true; // Crystal
        class1QualifyingTokenIds[191] = true; // Crystal
        class1QualifyingTokenIds[210] = true; // Hand
        class1QualifyingTokenIds[287] = true; // Kris
        class1QualifyingTokenIds[304] = true; // Eneko
        class1QualifyingTokenIds[340] = true; // Eneko
        class1QualifyingTokenIds[434] = true; // Eneko
        class1QualifyingTokenIds[288] = true; // Argus
        class1QualifyingTokenIds[339] = true; // Argus
        class1QualifyingTokenIds[408] = true; // Argus
        class1QualifyingTokenIds[451] = true; // Santa
        class1QualifyingTokenIds[453] = true; // Tiger
        class1QualifyingTokenIds[454] = true; // Tourny
        class1QualifyingTokenIds[456] = true; // Tourny
        class1QualifyingTokenIds[457] = true; // Tourny
        class1QualifyingTokenIds[458] = true; // Valentines
    }
    
    function userStatus() public view returns (
            bool saleEnabled,
            bool whitelisted, 
            uint256 class,
            uint256 alreadyPurchased,
            uint256 remaining,
            uint256 contractBalance,
            uint256 fapPrice,
            address busdAddress,
            uint256 busdApproved
        ) {
        saleEnabled = enabled;
        alreadyPurchased = fapToken.balanceOf(msg.sender);
        contractBalance = fapToken.balanceOf(address(this));
        (fapPrice, class) = getClass(msg.sender);
        whitelisted = fapPrice > 0;
        busdAddress = address(BUSD);
        busdApproved = BUSD.allowance(msg.sender, address(this));
        if (noLimit[msg.sender]) {
            remaining = contractBalance;
        } else if (whitelisted == false) {
            remaining = 0;
        } else {
            remaining = maxPurchase.sub(purchased[msg.sender]);  
        }
    }
    
    function exchange(uint256 amountBusd) public onWhitelist isEnabled {
        (uint256 rate,) = getClass(msg.sender);
        uint256 receivedFap = amountBusd.mul(rate).div(100);
        require(BUSD.transferFrom(msg.sender, wallet, amountBusd), "could not transfer BUSD");
        require(fapToken.balanceOf(address(this)) >= receivedFap, "not enough tokens left");
        uint256 p = purchased[msg.sender].add(amountBusd);
        if (noLimit[msg.sender] == false) {
            require(p <= maxPurchase, "you cannot purchase this many tokens");
        }
        require(p >= minPurchase, "minimum spend not met");
        purchased[msg.sender] = amountBusd;
        fapToken.transfer(msg.sender, receivedFap);
    }


    // Private methods

    function getClass(address who) private view returns (uint256 rate, uint256 class) {
        // Class 1
        if (
            fasyNft.balanceOf(who) >= class1QualifyingNftCount || 
            ownsClass1Token(who) ||
            class1Whitelist[who]
        ) {
            return (class1FapPerBusd, 1);
        }

        // Class 2
        if (
            fasyNft.balanceOf(who) > 0 ||
            class2Whitelist[who]
        ) {
            return (class2FapPerBusd, 2);
        }
        
        // Class 3
        if (
            openToAll || 
            class3Whitelist[who]
        ) {
            return (class3FapPerBusd, 3);
        }
        
        return (0, 0);
    }

    function ownsClass1Token(address who) private view returns (bool) {
        for (uint256 i = 0; i < fasyNft.balanceOf(who); i ++) {
            if (class1QualifyingTokenIds[fasyNft.tokenOfOwnerByIndex(who, i)]) {
                return true;
            }
        }
        return false;
    }

    
    // Admin methods
    function changeOwner(address who) public onlyOwner {
        require(who != address(0), "cannot be zero address");
        owner = who;
    }
    
    function enableSale(bool enable) public onlyOwner {
        enabled = enable;
    }

    function setOpenToall(bool enable) public onlyOwner {
        openToAll = enable;
    }
    
    function removeBnb() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function transferTokens(address token, address to) public onlyOwner returns(bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(to, balance);
    }
    
   function editMaxMinPurchase(uint256 _minPurchase, uint256 _maxPurchase) public onlyOwner {
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }
    
    function editWalletLimit(address who, bool hasNoLimit) public onlyOwner {
        noLimit[who] = hasNoLimit;
    }
    
    function editClass1Whitelist(address who, bool whitelisted) public onlyOwner {
        class1Whitelist[who] = whitelisted;
    }
    
    function editClass2Whitelist(address who, bool whitelisted) public onlyOwner {
        class2Whitelist[who] = whitelisted;
    }

    function editClass3Whitelist(address who, bool whitelisted) public onlyOwner {
        class3Whitelist[who] = whitelisted;
    }

    function editClass1FapPerBusd(uint256 amount) public onlyOwner {
        class1FapPerBusd = amount;
    }

    function editClass2FapPerBusd(uint256 amount) public onlyOwner {
        class2FapPerBusd = amount;
    }

    function editClass3FapPerBusd(uint256 amount) public onlyOwner {
        class3FapPerBusd = amount;
    }

    function editClass1MinNfts(uint256 amount) public onlyOwner {
        class1QualifyingNftCount = amount;
    }

    function addClass1QualifyingToken(uint256 tokenId, bool qualifies) public onlyOwner {
        class1QualifyingTokenIds[tokenId] = qualifies;
    }

    function bulkAddWhitelist(address[] memory people, uint256 class) public onlyOwner {
        require(class >= 1 && class <= 3, "invalid class");
        for (uint256 i = 0; i < people.length; i++) {
            if (class == 1) {
                editClass1Whitelist(people[i], true);
            } else if (class == 2) {
                editClass2Whitelist(people[i], true);
            } else if (class == 3) {
                editClass3Whitelist(people[i], true);
            }
        }
    }
}