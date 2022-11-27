/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/*  
 * ARK DepositNFTs
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

interface IPUBLICNFT {
    function presaleRoundOfNft(uint256 id) external view returns (uint256);
    function referrerOf(uint256 id) external view returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IPRIVATENFT {
    function contributionAmountOfId(uint256 id) external view returns (uint256);
    function referrerOf(uint256 id) external view returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ARK_DEPOSIT_NFT {
    address private CEO = 0x236e437177A19A0729E44f8612B2fDF2A3578FE8;
    IPRIVATENFT public constant PRIVATE_NFT = IPRIVATENFT(0xAaaA877f8dD9E8BE085575F00c9b383F90BFaAaA);
    IPUBLICNFT public constant PUBLIC_NFT = IPUBLICNFT(0xBBBBB1B2B0EEd447E1702c08E57215FcfDD3bbBB);

    mapping (address => address) public referrerOf;
    mapping (address => uint256) public totalArk;
    mapping (address => bool) public privateDepositedAlready;
    mapping (address => bool) public privateReferralPresent;
    mapping (address => uint256) public publicDepositedAlready;
    mapping (address => uint256) public idOfReferral;
    mapping (address => uint256) public depositActions;

    struct User{
        address investor;
        address referrer;
        uint256[] privateDeposited;
        uint256[] publicDeposited;
        uint256 claimableArk; 
    }

    User[] public depositers;
    mapping (address => uint256) public depositersIndex;

    uint256 public arkPricePrivate;

    bool public depositOpen = true;
    mapping (uint256 => uint256) public tokensOfRound;

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    event Deposited(address indexed user, address referrer, uint256 arkAmount, uint256 depositTimes);
    event PrivateDeposited(address investor, uint256 idPrivate, uint256 privateContribution, uint256 tokensFromPrivate);
    event PublicDeposited(address investor, uint256 idPublic, uint256 tokensFromPublic);
    
    constructor() {
        depositers.push();
        tokensOfRound[1] = 90 ether;
        tokensOfRound[2] = 80 ether;
        tokensOfRound[3] = 75 ether;
        arkPricePrivate = 2.75 ether;
    }

    function deposit() external {
        if(!depositOpen) return;
        uint256 userIndex = depositersIndex[msg.sender];
        if(userIndex == 0) {
            User memory user;
            depositersIndex[msg.sender] = depositers.length;
            userIndex = depositersIndex[msg.sender];
            user.investor = msg.sender;
            depositers.push(user);
        }

        depositActions[msg.sender]++;
        uint256 privateAmount = PRIVATE_NFT.balanceOf(msg.sender);
        uint256 publicAmount = PUBLIC_NFT.balanceOf(msg.sender);
        require(publicDepositedAlready[msg.sender] + publicAmount <= 4, "Maximum 4 public NFTs per wallet");

        uint256 totalArkOfWallet = 0;

        if(privateAmount > 0) {
            require(!privateDepositedAlready[msg.sender], "Can't deposit more than one private NFT");
            uint256 idPrivate = PRIVATE_NFT.tokenOfOwnerByIndex(msg.sender, 0);
            uint256 privateContribution = PRIVATE_NFT.contributionAmountOfId(idPrivate);
            uint256 tokensFromPrivate = privateContribution * 10**18 / arkPricePrivate;
            totalArkOfWallet += tokensFromPrivate;
            
            if(PRIVATE_NFT.referrerOf(idPrivate) != address(0)) {
                referrerOf[msg.sender] = PRIVATE_NFT.referrerOf(idPrivate);
                privateReferralPresent[msg.sender] = true;
            }

            PRIVATE_NFT.transferFrom(msg.sender, address(this), idPrivate);
            depositers[userIndex].privateDeposited.push(idPrivate);
            privateDepositedAlready[msg.sender] = true;
            emit PrivateDeposited(msg.sender, idPrivate, privateContribution, tokensFromPrivate);
        }

        if(publicAmount > 0) {
            uint256 idPublic;
            uint256 tokensFromPublic;
            
            for(uint256 i = 0; i<publicAmount; i++) {
                idPublic = PUBLIC_NFT.tokenOfOwnerByIndex(msg.sender, 0);
                tokensFromPublic = tokensOfRound[PUBLIC_NFT.presaleRoundOfNft(idPublic)];
                totalArkOfWallet += tokensFromPublic;
                
                if(!privateReferralPresent[msg.sender]) {
                    if(referrerOf[msg.sender] == address(0)) {
                        referrerOf[msg.sender] = PUBLIC_NFT.referrerOf(idPublic);
                        idOfReferral[msg.sender] = idPublic;
                    } else if(idOfReferral[msg.sender] > idPublic) {
                        referrerOf[msg.sender] = PUBLIC_NFT.referrerOf(idPublic);
                        idOfReferral[msg.sender] = idPublic;
                    }
                }

                PUBLIC_NFT.transferFrom(msg.sender, address(this), idPublic);
                depositers[userIndex].publicDeposited.push(idPublic);
               emit PublicDeposited(msg.sender, idPublic, tokensFromPublic);
            }
        }

        totalArk[msg.sender] += totalArkOfWallet;
        depositers[userIndex].claimableArk += totalArkOfWallet;
        depositers[userIndex].referrer = referrerOf[msg.sender];
        emit Deposited(msg.sender, referrerOf[msg.sender], totalArkOfWallet, depositActions[msg.sender]);
    }

    function closeDeposit() external onlyOwner {
        depositOpen = false;
    }

    // emergency functions just in case
    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }

    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getAllDepositers() public view returns(User[] memory) {
        return depositers;
    }

    function getDepositedPrivateId(address investor) public view returns (uint256) {
        return depositers[depositersIndex[investor]].privateDeposited[0];
    }

    function getDepositedPublicIds(address investor) public view returns (uint256[] memory) {
        return depositers[depositersIndex[investor]].publicDeposited;
    }

}