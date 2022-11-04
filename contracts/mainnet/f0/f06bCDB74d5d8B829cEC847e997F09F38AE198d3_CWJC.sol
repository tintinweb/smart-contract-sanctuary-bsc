// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./ITreasuryAddresses.sol";
import "./IERC721.sol";

// 2022.10.12 10:50 PM
contract CWJC is ERC20, ERC20Burnable, Ownable, Pausable {
    
    constructor() ERC20("Crypto Wave Jade Corals", "CWJC") {
        setpMBARate(600000000000000000000); 
    }

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


        // CTMT Codes starts here:
    address CTMTConAdd = address(this);
    address tmCTMTConAdd = 0xEE84A4eCB83efB9Ac30fD17c7B9A0C2127e1A11b;
    address cpCTMTConAdd = 0x940A275E4D62e24c8F72e6Ecd8B01a8594E34b87;
    address liCTMTConAdd = 0xbFa9Bb6FC2BB3897a7039A71c177c017F620e385;
    address giCTMTConAdd = 0x074571bb14507315Baf62430F3930B9AaD1C5d30;
    address grCTMTConAdd = 0x5F9DC9086DBE8051617bC97863eB6710d8F8Eb24;
    address sCTMTConAdd = 0x1AeC2EC95AAe87D00C51A33d0Cd9dF1CbA20cdEE;
    address stakingConAdd;
    address odMnstConAdd;
    address treasuryConAdd = 0xdeA16c78B98a9BfE9F13a84DAb0D53166f565331;    

    address pegTokenConAdd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address monstaTokenConAdd = 0x8A5d7FCD4c90421d21d30fCC4435948aC3618B2f;
    address DCNFTConAdd;

    IERC20 pegToken = IERC20(pegTokenConAdd);
    IERC20 monsta = IERC20(monstaTokenConAdd);

    IERC721 DCNFT;
        
    ITA iTA = ITA(treasuryConAdd);    

    uint coolDownTime = 7 days;
    uint public tokenEntryCount;

    uint public pMBA;
    uint public totalPMBA;
    uint public totalPmbaForSale;
    uint public allocationSold;

    mapping (address => uint) public pMBABal;
    mapping (address => uint) public pMBAForSale;

    mapping (address => uint) public proceedsRequestTime;
    mapping (address => uint256) public addressRegTokenId; 
    mapping (uint256 => uint16) public TokenLevel;

    mapping (uint256 => address) public ownerOfDCNFT;    
    mapping (address => uint) public readyPMBTimeOwner;
    mapping (uint256 => uint) public readyPMBTimeTokenId;
    

    mapping (uint => uint) public tokenEntryIdToTokenId;
    mapping (uint => uint) public tokenEntryIdToLevel;

    function setStakingConAdd(address Address) public onlyTreasurer {
        stakingConAdd = Address;
    }    

    function setOdMnstConAdd(address Address) public onlyTreasurer {
        odMnstConAdd = Address;
    } 

    function setDCNFTConAdd(address Address) public onlyTreasurer {
        DCNFTConAdd = Address;
        DCNFT = IERC721(Address);
    } 

    modifier onlyTreasurer() {
        require(_msgSender() == iTA.gTA(), "Caller is not the treasurer");
        _;
    }
        // for correction of records (correct level)
    function setCTokenLevel(uint256 tokenId, uint16 level) public onlyTreasurer {
        TokenLevel[tokenId] = level;
    }

        // to render additional days for correction of level
    function addDaysPenalty(address tokenOwner, uint timeAdjustment) public onlyTreasurer {
        readyPMBTimeOwner[tokenOwner] = timeAdjustment;        
    }

    function setpMBARate(uint allowance) public onlyTreasurer {
        require(allowance >= 0);
        require(allowance <= 100000000000000000000000);
        pMBA = allowance;        
    }

    function regPMinting(uint256 regTokenId, uint16 level) public virtual {
        require(_msgSender() == DCNFT.ownerOf(regTokenId), "You are not the owner of the DC NFT");

        addressRegTokenId[_msgSender()] = regTokenId;
        
        if(TokenLevel[regTokenId] == 0) {
            TokenLevel[regTokenId] = level;
            tokenEntryIdToTokenId[tokenEntryCount] = regTokenId;
            tokenEntryIdToLevel[tokenEntryCount] = level;
            tokenEntryCount += 1;
            }
        }

    function requestPMintingAllowance() public virtual {
        require(_msgSender() == DCNFT.ownerOf(addressRegTokenId[_msgSender()]));
        require(readyPMBTimeOwner[_msgSender()] <= block.timestamp, "Address is in cooldown.");
        uint tokenId = addressRegTokenId[_msgSender()];
        require(readyPMBTimeTokenId[tokenId] <= block.timestamp, "DC NFT is in cooldown.");

        uint minMBal; // divisor is 1,000,000, therefor 1,000 = 0.1% // minimum monsta balance
        uint pMBAll; // privileged minting/burning allowance
            if (TokenLevel[tokenId] == 5) {
                minMBal = monsta.totalSupply() * 1000 / 1000000;
                pMBAll = pMBA * 8;
                } else if (TokenLevel[tokenId] == 4) {
                    minMBal = monsta.totalSupply() * 750 / 1000000;
                    pMBAll = pMBA * 6;
                } else if (TokenLevel[tokenId] == 3) {
                    minMBal = monsta.totalSupply() * 500 / 1000000;
                    pMBAll = pMBA * 4;
                } else if (TokenLevel[tokenId] == 2) {
                    minMBal = monsta.totalSupply() * 250 / 1000000;
                    pMBAll = pMBA * 2;
                } else if(TokenLevel[tokenId] == 1) {
                    minMBal = monsta.totalSupply() * 125 / 1000000;
                    pMBAll = pMBA;
                } else {minMBal = monsta.totalSupply() * 1000000 / 1000000;
                        pMBAll = 0;
                }  
        require(monsta.balanceOf(_msgSender()) >= minMBal); 

            // Owner of DC NFTs can able to gain more allocation as long as they have active DC NFTs.
        pMBABal[_msgSender()] += pMBAll;
        totalPMBA += pMBAll;
        pegToken.transferFrom(_msgSender(), treasuryConAdd, pMBAll * 1 / 1000);
        readyPMBTimeOwner[_msgSender()] = block.timestamp + coolDownTime;
        readyPMBTimeTokenId[tokenId] = block.timestamp + coolDownTime;
    }

    function placePMBAForSale(uint amount) public {
        require(pMBABal[_msgSender()] >= amount, "Amount exceeds allocation");
        pMBAForSale[_msgSender()] += amount;
        pMBABal[_msgSender()] -= amount;
        totalPmbaForSale += amount;
        proceedsRequestTime[_msgSender()] = block.timestamp + coolDownTime;
    }

    function pullPMBAForSale(uint amount) public {
        require(pMBAForSale[_msgSender()] >= amount, "Amount exceeds allocation for sale");
        pMBAForSale[_msgSender()] -= amount;
        totalPmbaForSale -= amount;
        pMBABal[_msgSender()] += amount;
    }

    function buyPMBA(uint amount) public {
        require(totalPmbaForSale >= amount, "Insufficient allocation for sale");
        require((totalPmbaForSale - pMBAForSale[_msgSender()]) >= amount, "Buying own allocation is not allowed");
        pMBABal[_msgSender()] += amount;
        allocationSold += amount;
        totalPmbaForSale -= amount;
        uint ctmtAmount = amount * 1 / 100;
        pegToken.transferFrom(_msgSender(), CTMTConAdd, ctmtAmount);
        _mint(CTMTConAdd, ctmtAmount);
        
    }

    function getProceedsFrPMBASales(uint amount) public {
        require(allocationSold >= amount, "Amount exceeds allocation sold");
        require(block.timestamp >= proceedsRequestTime[_msgSender()]);
        pMBAForSale[_msgSender()] -= amount;
        _mint(_msgSender(), amount * 1 / 100);
        _burn(CTMTConAdd, amount * 1 / 100);
        allocationSold -= amount;
    }

    function BuyFromMint(uint amount) public virtual {

        require(pegToken.balanceOf(_msgSender()) >= amount, "Insufficient BUSD");

        if (pMBABal[_msgSender()] >= amount) {
            pegToken.transferFrom(_msgSender(), CTMTConAdd, amount * 99 / 100);
            pegToken.transferFrom(_msgSender(), treasuryConAdd, amount * 1 / 100);
            _mint(_msgSender(), amount * 99 / 100);
            pMBABal[_msgSender()] -= amount;
            totalPMBA -= amount;
        } else {
            uint allocDef = amount - pMBABal[_msgSender()];
            uint gFees = allocDef * 1 / 100;
            uint mintable = (amount * 99 / 100) - (gFees * 2);
            pegToken.transferFrom(_msgSender(), CTMTConAdd, amount * 99 / 100);
            pegToken.transferFrom(_msgSender(), treasuryConAdd, amount * 1 / 100);
            _mint(_msgSender(), mintable);
            _mint(grCTMTConAdd, gFees);
            _mint(giCTMTConAdd, gFees);
            totalPMBA -= pMBABal[_msgSender()];
            pMBABal[_msgSender()] = 0;
            }
    }

    function SelltoBurn(uint amount) public virtual {

        require(balanceOf(_msgSender()) >= amount, "Insufficient CTMT");
        
        if (pMBABal[_msgSender()] >= amount) {
            pegToken.transfer(_msgSender(), amount * 99 / 100);
            pegToken.transfer(treasuryConAdd, amount * 1 / 100);
            _burn(_msgSender(), amount);
            pMBABal[_msgSender()] -= amount;
            totalPMBA -= amount;
        } else {
            uint allocDef = amount - pMBABal[_msgSender()];
            uint gFees = allocDef * 1 / 100;
            uint returnable = (amount * 99 / 100) - (gFees * 2);
            pegToken.transfer(_msgSender(), returnable);
            pegToken.transfer(treasuryConAdd, amount * 1 / 100);
            _mint(grCTMTConAdd, gFees);
            _mint(giCTMTConAdd, gFees);            
            _burn(_msgSender(), amount);
            totalPMBA -= pMBABal[_msgSender()];
            pMBABal[_msgSender()] = 0;
            }
    }

    function surplusMint(address managerAdd, uint amount) public virtual returns (bool) {
        require(_msgSender() == tmCTMTConAdd);
        _surplusMint(managerAdd, amount);
        return true;
    }

    function _surplusMint(address managerAdd, uint amount) internal virtual {
        _mint(cpCTMTConAdd, amount * 50 / 100); // 50% for returns
        _mint(managerAdd, amount * 10 / 100);
        _mint(liCTMTConAdd, amount * 5 / 100);
        _mint(giCTMTConAdd, amount * 5 / 100);
        _mint(stakingConAdd, amount * 3 / 100);
        _mint(grCTMTConAdd, amount * 4 / 100);
        _mint(sCTMTConAdd, amount * 4 / 100);
        _mint(odMnstConAdd, amount * 3 / 100);
    }

    function tmMint(address mAdd, uint mAmount) public virtual returns (bool) {
        require(_msgSender() == tmCTMTConAdd);
            _mint(mAdd, mAmount);
        return true;
    }

    function tmBurn(address bAdd, uint bAmount) public virtual returns (bool) {
        require(_msgSender() == tmCTMTConAdd);
            _burn(bAdd, bAmount);
        return true;
    }

    function tmPegTransfer(address Add, uint tAmount) public virtual returns (bool) {
        require(_msgSender() == tmCTMTConAdd);
            pegToken.transfer(Add, tAmount);
        return true;
    }

    function providePegToken(uint amount) public virtual returns (bool) {
        require(_msgSender() == cpCTMTConAdd); 
        pegToken.transfer(tmCTMTConAdd, amount);
        _burn(cpCTMTConAdd, amount);
        return true;        
    }

}