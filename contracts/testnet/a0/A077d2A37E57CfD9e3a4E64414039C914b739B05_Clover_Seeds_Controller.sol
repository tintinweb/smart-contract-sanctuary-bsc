pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Clover_Seeds_Controller is Ownable {
    using SafeMath for uint256;

    address public Seeds_Token;
    address public Seeds_NFT_Token;
    address public teamWallet;
    address public rewardsWallet;
    address public Clover_Seeds_Picker;
    address public Clover_Seeds_Stake;

    uint256 public totalCloverFieldMinted;
    uint256 public totalCloverYardMinted;
    uint256 public totalCloverPotMinted;

    uint256 private _totalCloverYardMinted = 1e3;
    uint256 private _totalCloverPotMinted = 11e3;

    uint256 public totalCloverFieldCanMint = 1e3;
    uint256 public totalCloverYardCanMint = 1e4;
    uint256 public totalCloverPotCanMint = 1e5;

    uint256 private maximumTokenCanBuy = 10;
    
    uint256 public nftBuyFeeForTeam = 1000;
    uint256 public nftBuyFeeForMarketing = 1000;
    uint256 public nftBuyFeeForLiquidity = 3000;

    uint256 public yardBuyPriceUsingBNB = 15e16;

    uint256 public cloverFieldPrice = 1e22;
    uint256 public cloverYardPrice = 1e21;
    uint256 public cloverPotPrice = 1e20;

    bool public isContractActivated = false;

    mapping(address => bool) public isTeamAddress;
    mapping(address => bool) public isWhitelistedForPresell;
    mapping(address => bool) public isVIPAddress;
    mapping(address => uint256) public availableTokenCanBuy;
    
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
    
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public totalDepositedTokens;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public lastClaimedTime;

    mapping(uint256 => address) private _owners;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _Seeds_Token, address _Seeds_NFT_Token, address _teamWallet, address _rewardsWallet) {
        Seeds_Token = _Seeds_Token;
        Seeds_NFT_Token = _Seeds_NFT_Token;
        teamWallet = _teamWallet;
        rewardsWallet = _rewardsWallet;

        isCloverFieldCarbon[1] = true;
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

    function updateNftBuyFeeFor_Team_Marketing_Liquidity(uint256 _team, uint256 _mark, uint256 _liqu) public onlyOwner {
        nftBuyFeeForTeam = _team;
        nftBuyFeeForMarketing = _mark;
        nftBuyFeeForLiquidity = _liqu;
    }

    function buyCloverField1() public {
        require(totalCloverFieldMinted.add(1) <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 number = IContract(Clover_Seeds_Picker).getLuckyNumber();
        address luckyWalletForCloverField = IContract(Clover_Seeds_Stake).getLuckyWalletForCloverField();

        if (number >= 46 && number < 50) {
            if (luckyWalletForCloverField != address(0)) {
                to = luckyWalletForCloverField;
            }
        }

        uint256 liquidityFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForTeam);

        uint256 totalFee = liquidityFee.add(marketingFee).add(teamFee);
        uint256 forRewardsWallet = cloverFieldPrice.sub(totalFee);
        
        if (isTeamAddress[msg.sender]) {
            cloverFieldPrice = 0;
        }

        if (cloverFieldPrice > 0) {
            (IContract(Seeds_Token).Approve(address(this), cloverFieldPrice));
            IContract(Seeds_Token).transferFrom(msg.sender, address(this), cloverFieldPrice);
            IContract(Seeds_Token).transfer(Seeds_Token, totalFee);
            IContract(Seeds_Token).transfer(rewardsWallet, forRewardsWallet);
            IContract(Seeds_Token).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        
        uint256 tokenId = totalCloverFieldMinted.add(1);
        IContract(Seeds_NFT_Token).safeMint(to, tokenId);
    }

    function buyCloverYard() public {
        require(_totalCloverYardMinted.add(1) <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 number = IContract(Clover_Seeds_Picker).getLuckyNumber();
        address luckyWalletForCloverYard = IContract(Clover_Seeds_Stake).getLuckyWalletForCloverYard();

        if (number >= 46 && number < 50) {
            if (luckyWalletForCloverYard != address(0)) {
                to = luckyWalletForCloverYard;
            }
        }

        uint256 liquidityFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForTeam);

        uint256 totalFee = liquidityFee.add(marketingFee).add(teamFee);
        uint256 forRewardsWallet = cloverYardPrice.sub(totalFee);
        
        if (isTeamAddress[msg.sender]) {
            cloverYardPrice = 0;
        }

        if (cloverYardPrice > 0) {
            (IContract(Seeds_Token).Approve(address(this), cloverYardPrice));
            IContract(Seeds_Token).transferFrom(msg.sender, address(this), cloverYardPrice);
            IContract(Seeds_Token).transfer(Seeds_Token, totalFee);
            IContract(Seeds_Token).transfer(rewardsWallet, forRewardsWallet);
            IContract(Seeds_Token).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        
        uint256 tokenId = _totalCloverYardMinted.add(1);
        IContract(Seeds_NFT_Token).safeMint(to, tokenId);
    }

    function buyCloverPot() public {
        require(_totalCloverPotMinted.add(1) <= totalCloverPotCanMint, "Controller: All Clover Pot Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 number = IContract(Clover_Seeds_Picker).getLuckyNumber();
        address luckyWalletForCloverPot = IContract(Clover_Seeds_Stake).getLuckyWalletForCloverPot();

        if (number >= 46 && number < 50) {
            if (luckyWalletForCloverPot != address(0)) {
                to = luckyWalletForCloverPot;
            }
        }

        uint256 liquidityFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForTeam);

        uint256 totalFee = liquidityFee.add(marketingFee).add(teamFee);
        uint256 forRewardsWallet = cloverPotPrice.sub(totalFee);
        
        if (isTeamAddress[msg.sender]) {
            cloverPotPrice = 0;
        }

        if (cloverPotPrice > 0) {
            (IContract(Seeds_Token).Approve(address(this), cloverPotPrice));
            IContract(Seeds_Token).transferFrom(msg.sender, address(this), cloverPotPrice);
            IContract(Seeds_Token).transfer(Seeds_Token, totalFee);
            IContract(Seeds_Token).transfer(rewardsWallet, forRewardsWallet);
            IContract(Seeds_Token).AddFeeS(marketingFee, teamFee, liquidityFee);
        }
        
        uint256 tokenId = _totalCloverPotMinted.add(1);
        IContract(Seeds_NFT_Token).safeMint(to, tokenId);
    }

    function buyCloverField(uint256 numberOfToken) public {
        require(totalCloverFieldMinted.add(numberOfToken) <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(numberOfToken > 0 && numberOfToken < maximumTokenCanBuy, "Controller: Please enter a valid number..");
        require(availableTokenCanBuy[msg.sender] > 0 && numberOfToken <= availableTokenCanBuy[msg.sender], "Please enter a valid number..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 number = IContract(Clover_Seeds_Picker).getLuckyNumber();
        address luckyWalletForCloverField = IContract(Clover_Seeds_Stake).getLuckyWalletForCloverField();

        if (number >= 46 && number < 50) {
            if (luckyWalletForCloverField != address(0)) {
                to = luckyWalletForCloverField;
            }
        }

        availableTokenCanBuy[msg.sender] = availableTokenCanBuy[msg.sender].sub(numberOfToken);
        
        if (numberOfToken >= 1) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 2) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 3) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 4) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 5) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 6) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 7) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 8) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken >= 9) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
        
        if (numberOfToken == 10) {
            uint256 tokenId = totalCloverFieldMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, tokenId);
        }
    }

    function buyYardUsingBNB() public payable {
        require(totalCloverYardMinted.add(1) <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
        require(isWhitelistedForPresell[msg.sender], "Controller: You are not whitelisted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 number = IContract(Clover_Seeds_Picker).getLuckyNumber();
        address luckyWalletForCloverYard = IContract(Clover_Seeds_Stake).getLuckyWalletForCloverYard();

        if (number >= 46 && number < 50) {
            if (luckyWalletForCloverYard != address(0)) {
                to = luckyWalletForCloverYard;
            }
        }
        
        uint256 bnbAmount = msg.value;
        require(bnbAmount >= yardBuyPriceUsingBNB, "Controller: Please send valid amount..");
        
        if (bnbAmount >= yardBuyPriceUsingBNB && bnbAmount < yardBuyPriceUsingBNB.mul(2)) {
            uint256 Id = _totalCloverYardMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, Id);

            uint256 forTeamWallet = bnbAmount.sub(yardBuyPriceUsingBNB);
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }
        
        if (bnbAmount >= yardBuyPriceUsingBNB.mul(2)) {
            require(totalCloverYardMinted.add(2) <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
            uint256 Id = _totalCloverYardMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, Id);
            Id = _totalCloverYardMinted.add(1);
            IContract(Seeds_NFT_Token).safeMint(to, Id);

            uint256 forTeamWallet = bnbAmount.sub(yardBuyPriceUsingBNB.mul(2));
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }
    }

    function AddVIPs(address[] memory vipS, uint256[] memory numberOfToken) public onlyOwner {
        require(vipS.length == numberOfToken.length, "Controller: Please enter correct vipS & numberOfToken length...");
        for (uint256 i = 0; i < vipS.length; i++) {
            isVIPAddress[vipS[i]] = true;
            availableTokenCanBuy[vipS[i]] = availableTokenCanBuy[vipS[i]].add(numberOfToken[i]);
        }
    }

    function addMintedTokenId(uint256 tokenId) public returns (bool) {
        require(msg.sender == Seeds_NFT_Token, "Controller: Only for Seeds NFT..");
        
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

        return true;
    }

    function addOnWhitelistForYardPreSell(address[] memory accounts) public onlyOwner {
        
        for (uint256 i = 0; i < accounts.length; i++) {
            isWhitelistedForPresell[accounts[i]] = true;
        }
    }

    function addAsCloverFieldCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverFieldCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverFieldPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverFieldPearl[tokenId] = true;
        return true;
    }

    function addAsCloverFieldRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverFieldRuby[tokenId] = true;
        return true;
    }

    function addAsCloverFieldDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverFieldDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverYardCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverYardCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverYardPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverYardPearl[tokenId] = true;
        return true;
    }

    function addAsCloverYardRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverYardRuby[tokenId] = true;
        return true;
    }

    function addAsCloverYardDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverYardDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverPotCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverPotCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverPotPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverPotPearl[tokenId] = true;
        return true;
    }

    function addAsCloverPotRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverPotRuby[tokenId] = true;
        return true;
    }

    function addAsCloverPotDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_Picker, "Controller: You are not Clover_Seeds_Picker..");
        isCloverPotDiamond[tokenId] = true;
        return true;
    }

    function ActiveThisContract() public onlyOwner {
        isContractActivated = true;
    }

    function setClover_Seeds_Picker(address _Clover_Seeds_Picker) public onlyOwner {
        Clover_Seeds_Picker = _Clover_Seeds_Picker;
    }

    function setClover_Seeds_Stake(address _Clover_Seeds_Stake) public onlyOwner {
        Clover_Seeds_Stake = _Clover_Seeds_Stake;
    }

    function setRewards_Wallet(address _rewardsWallet) public onlyOwner {
        rewardsWallet = _rewardsWallet;
    }

    function setTeamAddress(address account) public onlyOwner {
        isTeamAddress[account] = true;
    }

    function set_Team_Wallet(address _teamWallet) public onlyOwner {
        teamWallet = _teamWallet;
    }

    function set_Seeds_Token(address SeedsToken) public onlyOwner {
        Seeds_Token = SeedsToken;
    }

    function set_Seeds_NFT_Token(address nftToken) public onlyOwner {
        Seeds_NFT_Token = nftToken;
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

    function setYardPriceInBNB(uint256 price) public onlyOwner {
        yardBuyPriceUsingBNB = price;
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Controller: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Controller: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }

    receive() external payable {
        buyYardUsingBNB();
    }
}

pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

interface IContract {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function safeMint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
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
    function getLuckyNumber() external returns (uint256);
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
}

pragma solidity 0.8.11;

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

pragma solidity 0.8.11;

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

pragma solidity 0.8.11;

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