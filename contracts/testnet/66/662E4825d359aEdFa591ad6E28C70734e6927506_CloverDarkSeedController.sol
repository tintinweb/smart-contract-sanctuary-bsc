pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract CloverDarkSeedController is Ownable {
    using SafeMath for uint256;

    address public CloverDarkSeedToken;
    address public CloverDarkSeedNFT;
    address public CloverDarkSeedPicker;
    address public CloverDarkSeedStake;
    address public CloverDarkSeedPotion;
    address public teamWallet;

    uint256 public totalCloverFieldMinted;
    uint256 public totalCloverYardMinted;
    uint256 public totalCloverPotMinted;

    uint256 private _totalCloverYardMinted = 1e3;
    uint256 private _totalCloverPotMinted = 11e3;

    uint256 public totalCloverFieldCanMint = 1e3;
    uint256 public totalCloverYardCanMint = 1e4;
    uint256 public totalCloverPotCanMint = 1e5;

    uint256 public maxMintAmount = 100;
    
    uint16 public nftBuyFeeForTeam = 40;
    uint16 public nftBuyFeeForMarketing = 60;
    uint16 public nftBuyFeeForLiquidity = 100;
    uint16 public nftBuyBurn = 300;

    uint256 public cloverFieldPrice = 1e20;
    uint256 public cloverYardPrice = 1e19;
    uint256 public cloverPotPrice = 1e18;

    uint8 public fieldPercentByPotion = 60;
    uint8 public yardPercentByPotion = 38;
    uint8 public potPercentByPotion = 2;

    uint256 public tokenAmountForPoorPotion = 5e17;
    bool public isContractActivated = false;

    mapping(address => bool) public isTeamAddress;
    mapping(address => uint16) public mintAmount;
    
    mapping(uint256 => bool) private isCloverFieldCarbon;
    mapping(uint256 => bool) private isCloverFieldPearl;
    mapping(uint256 => bool) private isCloverFieldRuby;
    mapping(uint256 => bool) private isCloverFieldDiamond;

    mapping(uint256 => bool) private isCloverYardCarbon;
    mapping(uint256 => bool) private isCloverYardPearl;
    mapping(uint256 => bool) private isCloverYardRuby;
    mapping(uint256 => bool) private isCloverYardDiamond;

    mapping(uint256 => bool) private isCloverPotCarbon;
    mapping(uint256 => bool) private isCloverPotPearl;
    mapping(uint256 => bool) private isCloverPotRuby;
    mapping(uint256 => bool) private isCloverPotDiamond;
    
    mapping(uint256 => address) private _owners;

    uint256 private lastMintedTokenId ;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _teamWallet, address _CloverDarkSeedToken, address _CloverDarkSeedNFT, address _CloverDarkSeedPotion) {
        CloverDarkSeedToken = _CloverDarkSeedToken;
        CloverDarkSeedNFT = _CloverDarkSeedNFT;
        CloverDarkSeedPotion = _CloverDarkSeedPotion;
        teamWallet = _teamWallet;
    }

    function isCloverFieldCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldCarbon[tokenId];
    }

    function isCloverFieldPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldPearl[tokenId];
    }

    function isCloverFieldRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldRuby[tokenId];
    }

    function isCloverFieldDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldDiamond[tokenId];
    }

    function isCloverYardCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverYardCarbon[tokenId];
    }

    function isCloverYardPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverYardPearl[tokenId];
    }

    function isCloverYardRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverYardRuby[tokenId];
    }

    function isCloverYardDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverYardDiamond[tokenId];
    }

    function isCloverPotCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverPotCarbon[tokenId];
    }

    function isCloverPotPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverPotPearl[tokenId];
    }

    function isCloverPotRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverPotRuby[tokenId];
    }

    function isCloverPotDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverPotDiamond[tokenId];
    }

    function updateNftBuyFeeFor_Team_Marketing_Liquidity(uint16 _team, uint16 _mark, uint16 _liqu, uint16 _burn) public onlyOwner {
        nftBuyFeeForTeam = _team;
        nftBuyFeeForMarketing = _mark;
        nftBuyFeeForLiquidity = _liqu;
        nftBuyBurn = _burn;
    }

    function freeMint(uint8 fieldCnt, uint8 yardCnt, uint8 potCnt, address acc) public onlyOwner {
        require(totalCloverFieldMinted + fieldCnt <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(totalCloverYardMinted + yardCnt <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
        require(totalCloverPotMinted + potCnt <= totalCloverPotMinted, "Controller: All Clover Pot Has Minted..");

        uint256 tokenID;
        for(uint8 i = 0; i < fieldCnt; i++) {
            IContract(CloverDarkSeedPicker).randomNumber(block.timestamp);
            tokenID = totalCloverFieldMinted + 1;
            IContract(CloverDarkSeedNFT).mint(acc, tokenID);
        } 
        for(uint8 i = 0; i < yardCnt; i++) {
            IContract(CloverDarkSeedPicker).randomNumber(block.timestamp);
            tokenID = _totalCloverYardMinted + 1;
            IContract(CloverDarkSeedNFT).mint(acc, tokenID);
        }  
        for(uint8 i = 0; i < potCnt; i++) {
            IContract(CloverDarkSeedPicker).randomNumber(block.timestamp);
            tokenID = _totalCloverPotMinted + 1;
            IContract(CloverDarkSeedNFT).mint(acc, tokenID);
        }      
    }

    function buyCloverField(uint256 entropy) public {
        require(totalCloverFieldMinted + 1 <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");
        address to = msg.sender;
        uint256 tokenId = totalCloverFieldMinted + 1;
        uint256 random = IContract(CloverDarkSeedPicker).randomNumber(entropy);

        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverField = IContract(CloverDarkSeedStake).getLuckyWalletForCloverField();
            if (luckyWalletForCloverField != address(0)) {
                to = luckyWalletForCloverField;
            }
        }

        uint256 liquidityFee = cloverFieldPrice.div(1e3).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverFieldPrice.div(1e3).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverFieldPrice.div(1e3).mul(nftBuyFeeForTeam);
        uint256 burnAmt = cloverFieldPrice.div(1e3).mul(nftBuyBurn);

        if (isTeamAddress[msg.sender]) {
            cloverFieldPrice = 0;
        }
        
        if (cloverFieldPrice > 0) {
            IContract(CloverDarkSeedToken).burnForNFT(burnAmt);
            IContract(CloverDarkSeedToken).Approve(address(this), cloverFieldPrice - burnAmt);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverFieldPrice - burnAmt);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        IContract(CloverDarkSeedNFT).mint(to, tokenId);

    }

    function buyCloverYard(uint256 entropy) public {
        require(totalCloverYardMinted + 1 <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 tokenId = _totalCloverYardMinted + 1;

        uint256 random = IContract(CloverDarkSeedPicker).randomNumber(entropy);
        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverYard = IContract(CloverDarkSeedStake).getLuckyWalletForCloverYard();
            if (luckyWalletForCloverYard != address(0)) {
                to = luckyWalletForCloverYard;
            }
        }

        uint256 liquidityFee = cloverYardPrice.div(1e3).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverYardPrice.div(1e3).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverYardPrice.div(1e3).mul(nftBuyFeeForTeam);
        uint256 burnAmt = cloverYardPrice.div(1e3).mul(nftBuyBurn);
        
        if (isTeamAddress[msg.sender]) {
            cloverYardPrice = 0;
        }

        if (cloverYardPrice > 0) {
            IContract(CloverDarkSeedToken).burnForNFT(burnAmt);
            IContract(CloverDarkSeedToken).Approve(address(this), cloverYardPrice - burnAmt);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverYardPrice - burnAmt);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        
        IContract(CloverDarkSeedNFT).mint(to, tokenId);
    }

    function buyCloverPot(uint256 entropy) public {
        require(totalCloverPotMinted + 1 <= totalCloverPotCanMint, "Controller: All Clover Pot Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 tokenId = _totalCloverPotMinted + 1;

        uint256 random = IContract(CloverDarkSeedPicker).randomNumber(entropy);
        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverPot = IContract(CloverDarkSeedStake).getLuckyWalletForCloverPot();
            if (luckyWalletForCloverPot != address(0)) {
                to = luckyWalletForCloverPot;
            }
        }

        uint256 liquidityFee = cloverPotPrice.div(1e3).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverPotPrice.div(1e3).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverPotPrice.div(1e3).mul(nftBuyFeeForTeam);
        uint256 burnAmt = cloverYardPrice.div(1e3).mul(nftBuyBurn);

        if (isTeamAddress[msg.sender]) {
            cloverPotPrice = 0;
        }

        if (cloverPotPrice > 0) {
            IContract(CloverDarkSeedToken).burnForNFT(burnAmt);
            IContract(CloverDarkSeedToken).Approve(address(this), cloverPotPrice - burnAmt);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverPotPrice - burnAmt);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        
        IContract(CloverDarkSeedNFT).mint(to, tokenId);
    }

    function setTokenForPoorPotion(uint256 amt) public onlyOwner {
        tokenAmountForPoorPotion = amt;
    }

    function setPotionPercentage(uint8 _potionField, uint8 _potionYard, uint8 _potionPot) public onlyOwner {
        fieldPercentByPotion = _potionField;
        yardPercentByPotion = _potionYard;
        potPercentByPotion = _potionPot;
    }
    function mintUsingPotion(uint256 entropy, bool isNormal) public {
        if (isNormal) {
            uint256 tokenID;
            uint256 random = IContract(CloverDarkSeedPicker).randomNumber(entropy) % 100;
            if (random < potPercentByPotion) {
                tokenID = _totalCloverPotMinted + 1;
            } else if (random < potPercentByPotion + yardPercentByPotion) {
                tokenID = _totalCloverYardMinted + 1;
            } else {
                tokenID = totalCloverFieldMinted + 1;
            }
            IContract(CloverDarkSeedNFT).mint(msg.sender, tokenID);
        } else {
            IContract(CloverDarkSeedToken).sendToken2Account(msg.sender, tokenAmountForPoorPotion);
        }
        IContract(CloverDarkSeedPotion).burn(msg.sender, isNormal);
    }

    function addMintedTokenId(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedNFT, "Controller: Only for Seeds NFT..");
        require(mintAmount[tx.origin] <= maxMintAmount, "You have already minted all nfts.");
        
        if (tokenId <= totalCloverFieldCanMint) {
            totalCloverFieldMinted = totalCloverFieldMinted.add(1);
        }

        if (tokenId > totalCloverFieldCanMint && tokenId <= totalCloverYardCanMint) {
            _totalCloverYardMinted = _totalCloverYardMinted.add(1);
            totalCloverYardMinted = totalCloverYardMinted.add(1);
        }

        if (tokenId > totalCloverYardCanMint && tokenId <= totalCloverPotCanMint) {
            _totalCloverPotMinted = _totalCloverPotMinted.add(1);
            totalCloverPotMinted = totalCloverPotMinted.add(1);
        }

        lastMintedTokenId = tokenId;
        mintAmount[tx.origin]++;
        return true;
    }

    function readMintedTokenURI() public view returns(string memory) {
        string memory uri = IContract(CloverDarkSeedNFT).tokenURI(lastMintedTokenId);
        return uri;
    }

    function addAsCloverFieldCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverFieldPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldPearl[tokenId] = true;
        return true;
    }

    function addAsCloverFieldRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldRuby[tokenId] = true;
        return true;
    }

    function addAsCloverFieldDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverYardCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverYardPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardPearl[tokenId] = true;
        return true;
    }

    function addAsCloverYardRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardRuby[tokenId] = true;
        return true;
    }

    function addAsCloverYardDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverPotCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverPotPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotPearl[tokenId] = true;
        return true;
    }

    function addAsCloverPotRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotRuby[tokenId] = true;
        return true;
    }

    function addAsCloverPotDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotDiamond[tokenId] = true;
        return true;
    }

    function ActiveThisContract() public onlyOwner {
        isContractActivated = true;
    }

    function setCloverDarkSeedPicker(address _CloverDarkSeedPicker) public onlyOwner {
        CloverDarkSeedPicker = _CloverDarkSeedPicker;
    }

    function setCloverDarkSeedStake(address _CloverDarkSeedStake) public onlyOwner {
        CloverDarkSeedStake = _CloverDarkSeedStake;
    }

    function setTeamAddress(address account) public onlyOwner {
        isTeamAddress[account] = true;
    }

    function set_CloverDarkSeedToken(address SeedsToken) public onlyOwner {
        CloverDarkSeedToken = SeedsToken;
    }

    function set_CloverDarkSeedNFT(address nftToken) public onlyOwner {
        CloverDarkSeedNFT = nftToken;
    }

    function setCloverFieldPrice(uint256 price) public onlyOwner {
        cloverFieldPrice = price;
    }

    function setCloverYardPrice(uint256 price) public onlyOwner {
        cloverYardPrice = price;
    }

    function setCloverPotPrice (uint256 price) public onlyOwner {
        cloverPotPrice = price;
    }

    function setCloverDarkPotion(address _CloverDarkSeedPotion) public onlyOwner {
        CloverDarkSeedPotion = _CloverDarkSeedPotion;
    }

    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Controller: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Controller: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IContract {
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
    function sendToken2Account(address, uint256) external returns(bool);
    function AddFeeS(uint256, uint256, uint256) external returns (bool);
    function addAsNFTBuyer(address) external returns (bool);
    function addMintedTokenId(uint256) external returns (bool);
    function addAsCloverFieldCarbon(uint256) external returns (bool);
    function addAsCloverFieldPearl(uint256) external returns (bool);
    function addAsCloverFieldRuby(uint256) external returns (bool);
    function addAsCloverFieldDiamond(uint256) external returns (bool);
    function addAsCloverYardCarbon(uint256) external returns (bool);
    function addAsCloverYardPearl(uint256) external returns (bool);
    function addAsCloverYardRuby(uint256) external returns (bool);
    function addAsCloverYardDiamond(uint256) external returns (bool);
    function addAsCloverPotCarbon(uint256) external returns (bool);
    function addAsCloverPotPearl(uint256) external returns (bool);
    function addAsCloverPotRuby(uint256) external returns (bool);
    function addAsCloverPotDiamond(uint256) external returns (bool);
    function randomLayer(uint256) external returns (bool);
    function randomNumber(uint256) external returns (uint256);
    function safeTransferFrom(address, address, uint256) external;
    function setApprovalForAll_(address) external;
    function isCloverFieldCarbon_(uint256) external returns (bool);
    function isCloverFieldPearl_(uint256) external returns (bool);
    function isCloverFieldRuby_(uint256) external returns (bool);
    function isCloverFieldDiamond_(uint256) external returns (bool);
    function isCloverYardCarbon_(uint256) external returns (bool);
    function isCloverYardPearl_(uint256) external returns (bool);
    function isCloverYardRuby_(uint256) external returns (bool);
    function isCloverYardDiamond_(uint256) external returns (bool);
    function isCloverPotCarbon_(uint256) external returns (bool);
    function isCloverPotPearl_(uint256) external returns (bool);
    function isCloverPotRuby_(uint256) external returns (bool);
    function isCloverPotDiamond_(uint256) external returns (bool);
    function getLuckyWalletForCloverField() external returns (address);
    function getLuckyWalletForCloverYard() external returns (address);
    function getLuckyWalletForCloverPot() external returns (address);
    function setTokenURI(uint256, string memory) external;
    function tokenURI(uint256) external view returns (string memory);
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
    //functions for potion
    function burn(address, bool) external;
    //function for token
    function burnForNFT(uint256) external;
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Context.sol";

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/OpenZeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}