/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0
///////////////////////////////////////////////////////////// 
// AcceleratedCostRecoveryContract
//
// The purpose of the contract is to help the companion 
// quickly compensate for the costs arising from the 
// lagging progress of its structure.
// In addition, the companion receives a double benefit, 
// since the delayed activation of the binaries in its 
// structure will still happen sooner or later.
//
// RECOMMENDED GAS LIMIT 200000.
/////////////////////////////////////////////////////////////
pragma solidity >=0.7.0 <0.9.0;

contract CompanionContractsRegistryContract {
    bool public isRegistryValid;
    address public ADMIN_ADDRESS;
}

contract AcceleratedCostRecoveryContract 
{
    struct CompanionCostRecoveryStruc {
        uint amountToCharity;
        uint amountCharitySended;
        string extendedInfo;
	}

    address public constant REGISTRY_CONTRACT = 0xc0A966Eb63648D0b6c419dA50488315eF00e2846;
	CompanionContractsRegistryContract private rt = CompanionContractsRegistryContract(REGISTRY_CONTRACT);

    address payable public companionCharityAddress;
    bool public isCharityStarted;
    bool public isBurn = false;
    mapping (address => CompanionCostRecoveryStruc) public ccrsMap;

    modifier isAdmin() 
    {
        require(msg.sender==rt.ADMIN_ADDRESS(), "Access denied.");
        _;
    }
    modifier isRegistryValid() 
    {
        require(rt.isRegistryValid(), "Access denied.");
        _;
    }
    function isCharityInProgress() public view returns (bool)
    {
        CompanionCostRecoveryStruc memory ccrs = ccrsMap[companionCharityAddress];
        return isCharityStarted &&
            ccrs.amountToCharity >
            ccrs.amountCharitySended;
    }
    function withdraw() isAdmin external  
    {
        require(address(this).balance > 0, "No funds.");
        require(!isCharityInProgress(),
            "Access denied, charity in progress yet.");
        payable(msg.sender).transfer(address(this).balance);
    }
    function makeCharity() private 
    {
        if(!isCharityStarted || 
            (companionCharityAddress == address(0) &&
             !isBurn))
            return;
        CompanionCostRecoveryStruc storage ccrs = ccrsMap[companionCharityAddress];
        if(ccrs.amountCharitySended < 
            ccrs.amountToCharity)
        {
            unchecked
            {
                uint amount = ccrs.amountToCharity - ccrs.amountCharitySended;
                if(amount > address(this).balance)
                    amount = address(this).balance;
                if(amount > 0)
                {
                    companionCharityAddress.transfer(amount);
                    ccrs.amountCharitySended += amount;
                }
            }
        }
    }
    function setExtendedInfo2(address companion, string calldata info) isAdmin isRegistryValid external payable
    {
        ccrsMap[companion].extendedInfo = info;
    }
    function setExtendedInfo(string calldata info) isAdmin isRegistryValid external payable
    {
        ccrsMap[companionCharityAddress].extendedInfo = info;
    }
    function appendExtendedInfoPrivate(address companion, string calldata info) private
    {
        CompanionCostRecoveryStruc storage ccrs = ccrsMap[companion];
        ccrs.extendedInfo = string.concat(ccrs.extendedInfo, info);
    }
    function appendExtendedInfo2(address companion, string calldata info) isAdmin isRegistryValid external payable
    {
        appendExtendedInfoPrivate(companion, info);
    }
    function appendExtendedInfo(string calldata info) isAdmin isRegistryValid external payable
    {
        appendExtendedInfoPrivate(companionCharityAddress, info);
    }
    function setAmountToCharity(uint amount) isAdmin isRegistryValid external payable
    {
        ccrsMap[companionCharityAddress].amountToCharity = amount;
    }
    function setAmountCharitySended(uint amount) isAdmin isRegistryValid external payable
    {
        ccrsMap[companionCharityAddress].amountCharitySended = amount;
    }
	function setAmountToCharity2(address companion, uint amount) isAdmin isRegistryValid external payable
    {
        ccrsMap[companion].amountToCharity = amount;
    }
    function setAmountCharitySended2(address companion, uint amount) isAdmin isRegistryValid external payable
    {
        ccrsMap[companion].amountCharitySended = amount;
    }
    function setCompanionCharityAddress(address addr) isAdmin isRegistryValid external payable
    {
        companionCharityAddress = payable(addr);
    }
    function setBurn(bool isBurnFlag) isAdmin isRegistryValid external payable
    {
        isBurn = isBurnFlag;
        if(isBurn)
            companionCharityAddress = payable(address(0));
        if(msg.value > 0)
            makeCharity();
    }
    function setAllCharityDataPrivate(address companion, uint paramAmountToCharity, uint paramAmountCharitySended, string memory info) private
    {
        CompanionCostRecoveryStruc storage ccrs = ccrsMap[companion];
        companionCharityAddress = payable(companion);
        ccrs.amountToCharity = paramAmountToCharity;
        ccrs.amountCharitySended = paramAmountCharitySended;
        ccrs.extendedInfo = info;
        if(msg.value > 0)
            makeCharity();
    }

    function setAllCharityData(address companion, uint paramAmountToCharity, uint paramAmountCharitySended, string calldata info) isAdmin isRegistryValid external payable
    {
        setAllCharityDataPrivate(companion, paramAmountToCharity, paramAmountCharitySended, info);
    }
    function appendAllCharityData(address companion, uint paramAmountToCharity, uint paramAmountCharitySended, string calldata info) isAdmin isRegistryValid external payable
    {
        CompanionCostRecoveryStruc memory ccrs = ccrsMap[companion];
		unchecked
		{
			setAllCharityDataPrivate(
				companion,
				paramAmountToCharity + ccrs.amountToCharity,
				paramAmountCharitySended + ccrs.amountCharitySended, 
				string.concat(ccrs.extendedInfo, info)
			);
		}
    }
    function setCharityStarted(bool isStarted) isAdmin isRegistryValid external payable
    {
        isCharityStarted = isStarted;
        if(isStarted && address(this).balance > 0)
            makeCharity();
    }
    receive() external payable 
    {
        makeCharity();
    }    
}