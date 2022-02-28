/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
}

// File: contracts/stack.sol

//  SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;



interface AwesomeNfts {
    function stackMoreNFT(uint _tokenId, address _from) external returns(bool); 
    function unStackMoreNFT(uint _tokenId, address _from) external returns(bool);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function walletOfOwner(address _owner)                            
    external
    view
    returns (uint256[] memory);
}

interface IERC721 {
    function stackMoreNFT(uint _tokenId, address _from) external returns(bool); 
    function unStackMoreNFT(uint _tokenId, address _from) external returns(bool);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function CORAL_PRICE() external view returns (uint);
    function PEARL_PRICE() external view returns (uint);
    function DIAMOND_PRICE() external view returns (uint);
    function types(uint _token) external view returns (uint);
    function walletOfOwner(address _owner)                            
    external
    view
    returns (uint256[] memory);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract NftStacking is Ownable{
    uint public duration; //set duration for all the unsumers;
    mapping(address => Stack) public stackingUsers; //it's hold all the stacking users;
    mapping(address => Token[]) public userTokens;
    mapping(uint => analysis[]) public Analysis;

    uint public contractStartTime = 0;
    uint public lastInvestment = 0;
    uint public PERAL_PERCENT = 20;
    uint public CORAL_PERCENT = 24;
    uint public DIAMOND_PERCENT = 28;


    address public ContractAddress;
    address public CoinContractAddress;

    uint TokenNeeded = 0;
    Token[] private temp;
    analysis[] private analytics;

    event recipt(address _user, uint _timestamp, Check _check, uint _transferAmount);
    
    struct Stack {
        uint [] tokens;
        uint startTime;
        uint nftPrice;
        uint rewardTime;    
    }

    struct Token {
        uint tokenId;
        uint start;
        uint reward;
        uint price;
    }

    struct Days {
        uint remain;
        uint current;
        uint least;
    }

    struct Check {
        Days day;
        uint fund;
    }

    struct analysis {
        uint _price;
    }

    constructor(
        address _nftContract
    ) {
        contractStartTime = block.timestamp;
        ContractAddress = _nftContract;
    }

    function stackOneNft(
        uint _token,
        address _user
    ) public returns(bool) {
        AwesomeNfts an = AwesomeNfts(ContractAddress);
        delete temp;
        temp = userTokens[_user];
        require(_user == msg.sender, "sorry! you are not nft owner");
        address _currentUser = an.ownerOf(_token);
        require(_user == _currentUser, "Invalid Token Id");
        for (uint a = 0 ; a < temp.length; a++) {
            if(temp[a].tokenId == _token && temp[a].price != 0){
                require(temp[a].tokenId != _token, "Token Already Stacked");
            }
        }
        uint price = getPrice(_token);
        Token memory token = Token(_token, block.timestamp, block.timestamp, price);
        temp.push(token);
        userTokens[_user] = temp;
        an.stackMoreNFT(_token, _user);
        setAnalysis(price);
        return true;
    }


    function getPrice(uint _token) public view returns(uint) {
        IERC721 nft = IERC721(ContractAddress);
        uint coral = nft.CORAL_PRICE();
        uint peral = nft.PEARL_PRICE();
        uint diamond = nft.DIAMOND_PRICE();
        uint TYPE = nft.types(_token);
        uint price = 0;
        if(TYPE == 0){
            price = (diamond * DIAMOND_PERCENT) / 100;
        } else if (TYPE == 1) {
            price = (coral * CORAL_PERCENT) / 100;
        } else if (TYPE == 2) {
            price = (peral * PERAL_PERCENT) / 100;
        } 

        return price;
    }

    function setAnalysis(uint _price) private returns(bool) {
        delete analytics;
        uint day  = (block.timestamp - contractStartTime) / 1 days;

        if(day <= lastInvestment) {
            day = lastInvestment;
        }

        day = day + 30;
        analytics = Analysis[day];
        analytics.push(analysis(_price));
        Analysis[day] = analytics; 
        return true;
    }

    function getPriceOfTheDay(uint _timestamp) public view returns (analysis[] memory) {
        return Analysis[_timestamp];
    }

    function unStackNft(
        address _user,
        uint _token
    ) public returns(bool) {
        AwesomeNfts an = AwesomeNfts(ContractAddress);
        delete temp;
        temp = userTokens[_user];

        for(uint i=0; i<temp.length; i++) {
            if(temp[i].tokenId == _token) {
                an.unStackMoreNFT(temp[i].tokenId, _user);
                delete temp[i];
            }
        }

        if(temp.length == 0) {
            delete userTokens[_user];
        }

       
        userTokens[_user] = temp;
        return true;
    }


    function claimReward(
        address _user,
        uint _token
    ) public payable returns(Check memory) {
        delete temp;
        temp = userTokens[_user];
        Check memory check;
        require(_user == msg.sender, "sorry! but you are not owner");

        for(uint i=0; i < temp.length; i++) {
            if(temp[i].tokenId == _token) {
                require(temp[i].reward + 1 minutes < block.timestamp, "Claim Reward Duration Is Not Over");
                Days memory d = differenceInDays(temp[i].reward, block.timestamp);
                uint daysOfMonths = d.least * temp[i].price;

                if(d.current > 0) {
                    temp[i].reward = d.current;
                } 

                check = Check(d, daysOfMonths);
                break;
            }
        }

        // IERC20 erc20 = IERC20(CoinContractAddress);
        payable (_user).transfer(check.fund);
        userTokens[_user] = temp;
        emit recipt(_user, block.timestamp, check, check.fund);
        return check;
    }

    function getShares(uint _price) private pure returns (uint) {
         uint percent = 0;

         if(_price <= 50) {
             percent = (_price * 22) / 100;
         } else if((_price > 50) && (_price <= 200)) {
             percent = (_price * 25) / 100;
         } else if(_price > 200) {
             percent = (_price * 28) / 100;
         }

         return percent;
    }

     function differenceInDays(uint _startTime, uint _endTime) internal pure returns(Days memory) {
        uint day = ((_endTime - _startTime) / 1 hours); 
        uint t = 1;
        Days memory s;
        if(day > 1) {
            uint last = 0;
            for(uint i=0; i < 24; i++) {
                if(day >= (t * i)) {
                    last = t * i;
                } else {
                    uint remain = day - last;
                    uint ntime = 1 hours * remain;
                    uint newDay = _endTime + ntime;
                    s = Days(remain, newDay, last);
                }
            }
        } else {
            require(day > 1, "Time is reamaining");
        }
    return s;
    }

    function setContractAddress(
        address _contractAddress
    ) public onlyOwner {
        ContractAddress = _contractAddress;
    }

    function setCoinContractAddress(
        address _contractAddress
    ) public onlyOwner {
        CoinContractAddress = _contractAddress;
    }

    function getCointInfo(
        address _contractAddress
    ) public view returns(uint) {
        IERC20 coin = IERC20(CoinContractAddress);
        return coin.balanceOf(_contractAddress);
    }

    function stacked(
        address _user
    ) public view returns(Token[] memory) {
        return userTokens[_user];
    }

    function setPercent(
        uint _coral,
        uint _peral,
        uint _diamond
    ) public onlyOwner {
        PERAL_PERCENT = _peral;
        CORAL_PERCENT = _coral;
        DIAMOND_PERCENT = _diamond;
    }

    fallback () payable external {
    } 

    receive () payable external {
    }

    function withdrawal(address _user) payable public onlyOwner {
        payable (_user).transfer(address(this).balance);
    }
}