// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./Pausable.sol";

interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

}

contract CTMToken01 is ERC20, ERC20Burnable, Ownable, Pausable, IERC721 {
    constructor() ERC20("Crypto Trading Management Token 01", "CTMT01") {
        _treasurer = _msgSender();
        assignmonstaTokenAddress(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95);
        monstaTokenAddress = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95;
        setDiamondClawsNFTAddress(0x9ecEA68DE55F316B702f27eE389D10C2EE0dde84);
        DiamondClawsNFTAddress = 0x9ecEA68DE55F316B702f27eE389D10C2EE0dde84;
        assignPegAddress(0xd9145CCE52D386f254917e481eB44e9943F39138);
        PegAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    }

    address PegAddress;
    address monstaTokenAddress;
    address DiamondClawsNFTAddress;



    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // CMTT codes starts here

        // Set treasurer function
        // Testing done

    address private _treasurer;

    event TreasuryTransferred(address indexed oldTreasurer, address indexed newTreasurer);

    modifier onlyTreasurer() {
    _checkTreasurer();
    _;
    }

    function assignFirstTreasurer(address firstTreasurer) public virtual onlyOwner {
        _treasurer = firstTreasurer;
    }

    function treasurer() public view virtual returns (address) {
    return _treasurer;
    }

    function _checkTreasurer() internal view virtual {
        require(treasurer() == _msgSender(), "Treasury: caller is not the treasurer");
    }  

    function transferTreasury(address newTreasurer) public virtual onlyTreasurer {
        require(newTreasurer != address(0), "Treasury: new owner is the zero address");
        _transferTreasury(newTreasurer);
    }

    function _transferTreasury(address newTreasurer) internal virtual {
        address oldTreasurer = _treasurer;
        _treasurer = newTreasurer;
        addressMinterType[newTreasurer] = "Treasurer";

        emit TreasuryTransferred(oldTreasurer, newTreasurer);
    }

        // End of treasurer function

        // Minting and Burning for Pegged Token (e.g. BUSD)
    
    // Peg Token Interface
    IERC20 pegToken;

    function assignPegAddress(address newpegAddress) public virtual onlyTreasurer {
    pegToken = IERC20(newpegAddress);
    }

    // Distribution address of shares of Global Reserves and Global Insurance in inital minting.
    address _grCTMTAddress = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
    address _giCTMTAddress = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;

    function setgrCTMTAddress(address newgrCTMTAddress) public virtual onlyOwner {
    _grCTMTAddress = newgrCTMTAddress;
    }

    function setgiCTMTAddress(address newgiCTMTAddress) public virtual onlyOwner {
    _giCTMTAddress = newgiCTMTAddress;
    }

    uint pMintBurnAllowanceCoolDownTime = 7 days;

    // CTMTMinter's table

    mapping (address => bool) public isaddressRegisteredMinter;
    mapping (address => string) public addressMinterType;
    mapping (address => uint256) public addressRegTokenId;  
    mapping (uint256 => address) public ownerOfDCNFT; 
    mapping (address => uint) public pMintingAllocationBalance;
    mapping (address => uint) public readyPMintingBurningtime;
    mapping (uint256 => uint16) public TokenLevel;

    // Registration Functions
    function registerAsRegularMinting() public virtual {
        isaddressRegisteredMinter[_msgSender()] = true;
        addressMinterType[_msgSender()] = "Regular";
    }

        
        // DC NFT Requirement
    IERC20 monstaToken;

    function assignmonstaTokenAddress(address newmonstaTokenAddress) public virtual onlyTreasurer {
    monstaToken = IERC20(newmonstaTokenAddress);
    }


        // Monsta Requirement
    IERC721 DiamondClawsNFT;

    function setDiamondClawsNFTAddress(address newDiamondClawsNFTAddress) public virtual onlyTreasurer {
    DiamondClawsNFT = IERC721(newDiamondClawsNFTAddress);
    }

        // 
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = ownerOfDCNFT[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

        // for correction of records (correct level)
    function setcorrectTokenLevel(uint256 tokenId, uint16 level) public onlyTreasurer {
        TokenLevel[tokenId] = level;

    }

        // to render additional days for correction of level
    function addDaysPenalty(address tokenOwner, uint daysPenalty) public onlyTreasurer {
        uint prevReadyPMintingBurningtime = readyPMintingBurningtime[tokenOwner];
        uint penaltyInUint = daysPenalty * 60 * 60 * 24;
        readyPMintingBurningtime[tokenOwner] = prevReadyPMintingBurningtime + penaltyInUint;        
    }

        /*  Minting operations 
            Registration requirements
                1. Owner of DCNFT;
                2. 
        */

        // For testing only
    function checkownerDCNFT(uint256 tokenId) public view returns (address) {
        return DiamondClawsNFT.ownerOf(tokenId);
    }

    function checkBalanceOf(address owner) public view returns (uint) {
        return pegToken.balanceOf(owner);
    }

    function approveTreasurer(uint amount) public {
        pegToken.approve(_treasurer, amount * 10 ** 18);
    }

    function tranferToTreasurer(uint amount) public {
        pegToken.transfer(_treasurer, amount * 10 ** 18); // In BUSD
    }

    function registerPMinting(uint256 regTokenId, uint16 level) public virtual {
        require(_msgSender() == DiamondClawsNFT.ownerOf(regTokenId));
        require(level > 0, "Token Id. 0 is not qualified");

        isaddressRegisteredMinter[_msgSender()] = true; //Registry of registration
        addressMinterType[_msgSender()] = "Privileged"; //registry of privileged
        readyPMintingBurningtime[_msgSender()] = block.timestamp; // The minter can start minting
        addressRegTokenId[_msgSender()] = regTokenId;
        
        if(TokenLevel[regTokenId] == 0) {
            TokenLevel[regTokenId] = level;}
            else {TokenLevel[regTokenId] = 50000;}

    }


    function requestPMintingAllowance() public virtual {
        require(keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Privileged")), "The caller is not privileged");   
        require(_msgSender() == DiamondClawsNFT.ownerOf(addressRegTokenId[_msgSender()]));
        require(readyPMintingBurningtime[_msgSender()] <= block.timestamp);

        uint minimumMonstaBal; // divisor is 1,000,000, therefor 1,000 = 0.1%
        uint tokenId = addressRegTokenId[_msgSender()];
        uint newpMintingAllocation;
            if (TokenLevel[tokenId] == 5) {
                minimumMonstaBal = monstaToken.totalSupply() * 1000 / 1000000;
                newpMintingAllocation = 2400 * 10 ** 18;
                } else if (TokenLevel[tokenId] == 4) {
                    minimumMonstaBal = monstaToken.totalSupply() * 750 / 1000000;
                    newpMintingAllocation = 1800 * 10 ** 18;
                } else if (TokenLevel[tokenId] == 3) {
                    minimumMonstaBal = monstaToken.totalSupply() * 500 / 1000000;
                    newpMintingAllocation = 1200 * 10 ** 18;
                } else if (TokenLevel[tokenId] == 2) {
                    minimumMonstaBal = monstaToken.totalSupply() * 250 / 1000000;
                    newpMintingAllocation = 600 * 10 ** 18;
                } else if(TokenLevel[tokenId] == 1) {
                    minimumMonstaBal = monstaToken.totalSupply() * 125 / 1000000;
                    newpMintingAllocation = 300 * 10 ** 18;
                } else {minimumMonstaBal = monstaToken.totalSupply() * 1000000 / 1000000;
                        newpMintingAllocation = 0;
                }  
        require(monstaToken.balanceOf(_msgSender()) >= minimumMonstaBal); 

            // Owner of DC NFTs can able to gain more allocation as long as they have active DC NFTs.
        pMintingAllocationBalance[_msgSender()] = pMintingAllocationBalance[_msgSender()] + newpMintingAllocation;
        readyPMintingBurningtime[_msgSender()] = block.timestamp + pMintBurnAllowanceCoolDownTime; // Mint/Burn after 7 days
    }


    // Minting and Burning of CTMT in exchanged of USD Pegged token
    // Approval for treasurer will be 1 time;

    address CTMTContractAdrress = address(this);

    function setCTMTContractAdrress(address _address) public onlyOwner {
        CTMTContractAdrress = _address;
    }

    function BuyFromMint(uint256 amount) public virtual {
        require(isaddressRegisteredMinter[_msgSender()] = true, "The caller is not a registered minter.");
        
        uint rAmount = amount * 10 * 18; // rAmount or real amount
        if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Regular"))) {
            pegToken.approve(CTMTContractAdrress, rAmount);
            pegToken.transferFrom(_msgSender(), CTMTContractAdrress, rAmount);
            pegToken.transferFrom(CTMTContractAdrress, _treasurer, rAmount * 1 / 100);
            _mint(msg.sender, rAmount  * 97 / 100);
            _mint(_grCTMTAddress, rAmount  * 1 / 100);
            _mint(_giCTMTAddress, rAmount  * 1 / 100);
        } else if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Privileged"))) {
            require(pMintingAllocationBalance[_msgSender()] >= rAmount);
            pegToken.approve(CTMTContractAdrress, rAmount);
            pegToken.transferFrom(_msgSender(), CTMTContractAdrress, rAmount);
            pegToken.transferFrom(CTMTContractAdrress, _treasurer, rAmount * 1 / 100);
            _mint(msg.sender, rAmount * 99 / 100);
            pMintingAllocationBalance[_msgSender()] = pMintingAllocationBalance[_msgSender()] - rAmount;
        } else if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Treasurer"))) {
            pegToken.transferFrom(_msgSender(), CTMTContractAdrress, rAmount);
            _mint(msg.sender, rAmount);
        } else {revert();}
    }

    function SelltoBurn(uint256 amount) public virtual {
        require(isaddressRegisteredMinter[_msgSender()] = true, "The caller has no privilege.");
        
        uint rAmount = amount * 10 * 18;
        if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Regular"))) {
            pegToken.approve(_msgSender(), rAmount * 97 / 100);
            pegToken.transferFrom(CTMTContractAdrress, _msgSender(), rAmount * 97 / 100); // Check if apporval is necessary
            pegToken.transferFrom(CTMTContractAdrress, _treasurer, rAmount * 3 / 100);
            _burn(_msgSender(), rAmount);
            _spendAllowance(CTMTContractAdrress, _msgSender(), rAmount);
        } else if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Privileged"))) {
            require(pMintingAllocationBalance[_msgSender()] >= amount);
            pegToken.approve(_msgSender(), rAmount * 99 / 100);
            pegToken.transferFrom(CTMTContractAdrress, _msgSender(), rAmount * 99 / 100);
            pegToken.transferFrom(CTMTContractAdrress, _treasurer, rAmount * 1 / 100);
            _burn(_msgSender(), rAmount);
            _spendAllowance(CTMTContractAdrress, _msgSender(), rAmount);
            pMintingAllocationBalance[_msgSender()] = pMintingAllocationBalance[_msgSender()] - rAmount;
        } else if (keccak256(abi.encodePacked(addressMinterType[_msgSender()])) == keccak256(abi.encodePacked("Treasurer"))) {
            pegToken.transferFrom(CTMTContractAdrress, _msgSender(), rAmount);
            _spendAllowance(CTMTContractAdrress, _msgSender(), rAmount);
            _burn(_msgSender(), rAmount);
        } else {revert();}        
    }

}