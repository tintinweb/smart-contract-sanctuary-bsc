// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint256 value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}

interface iBlacklist {
    function getBlacklist(address _address, address _contract) external view returns (uint256 is_blacklisted);
}

interface iAuditor {
    function getVerified(address _contract) external view returns (uint256 is_verified);
}

contract Sale is ReentrancyGuard {
    struct SaleDetails {
        address sale_token;          // Sale token
        uint256 canceled;               // Canceled flag
        uint256 hasSeedRound;           // Sale has a seed round
        uint256 hasPresaleRound;        // Sale has a presale round
        uint256 hasCommunityRound;      // Sale has a community round
        uint256 listRate;            //
        uint256 saleOption;             //
        uint256 hasVesting;
        uint256 launchFee;
        uint256 coupon;
        uint256 couponNumber;
        uint256 router;
    }

    struct SaleInfo {
        uint256 token_rate;          // 1 base token = ? s_tokens, fixed price
        uint256 raise_min;           // Maximum base token BUY amount per buyer
        uint256 raise_max;           // The amount of sale tokens up for sale round
        uint256 softcap;             // Minimum raise amount
        uint256 hardcap;             // Maximum raise amount
        uint256 start;               // Start date of the sale
        uint256 end;                 // End date of the sale
        uint256 liquidity;           // Liquidity of the sale
        uint256 liquidityLock;       // Duration of the liquidity lock in minutes
        uint256 liquidityTokens;     //
        uint256 sale_type;           // Sale type, 1 = whitelist or 0 = public availability
        uint256 attempt;                // Attempt of the
        uint256 mult;
        uint256 multT;
    }

    struct SaleVesting {
        uint256 TGE;                 // token generation event date
        uint256 TGE_amount;          // amount at the token generation amount
        uint256 cliff;               // cliff date
        uint256 period;              // Maximum raise amount
        uint256 period_amount;       // Start date of the sale
    }

    struct SaleStatus {
        uint256 force_failed;           // Set this flag to force fail the sale
        uint256 sale_raised_amount;  // Total base currency raised (usually ETH)
        uint256 sale_sold_amount;    // Total sale tokens sold
        uint256 sale_token_withdraw; // Total tokens withdrawn post successful sale
        uint256 sale_base_withdraw;  // Total base tokens withdrawn on sale failure
        uint256 sale_num_buyers;     // Number of unique participants
    }

    struct BuyerInfo {
        uint256 sale_base;           // Total base token (usually ETH) deposited by user, can be withdrawn on sale failure
        uint256 sale;                // Num sale tokens a user owned, can be withdrawn on sale success
        uint256 last_deposit;
        uint256 TGE_claimable;
        uint256 claimable;
        uint256 TGE_claimed;
        uint256 claimed;
    }

    struct TokenInfo {
        string name;                 //
        string symbol;               //
        uint256 totalsupply;         //
        uint256 decimal;             //
    }

    address owner;
    address public admin = 0x33F3ed84725FdbF32Ea78F3a576c0c35a92b7a7e;
    address public feeAddress = 0x33F3ed84725FdbF32Ea78F3a576c0c35a92b7a7e;
    address public blacklistContract = 0x9844568F3E376Fc0363E634D7D54D1EEa1969440;
    address public auditorContract = 0xbdE7fc94527a84a856B65eC54803c71B923a54Ea;

    address _address = msg.sender;
    address _contract = address(this);

    SaleDetails internal sale_details;
    mapping(uint256 => SaleInfo) internal sale_info;
    mapping(uint256 => SaleVesting) internal sale_vesting;
    mapping(uint256 => SaleStatus) internal sale_status;
    mapping(uint256 => mapping(address => BuyerInfo)) internal buyers;
    
    TokenInfo internal tokeninfo;

    uint256 saleSetting;

    mapping(address => uint) internal saleWhitelistInfo;

    event SaleCreated(address, address);
    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);
    event UserWithdrawTokensVestingSuccess(uint256, uint256);

    address deadaddr = 0x000000000000000000000000000000000000dEaD;
    uint256 public sale_lock_delay;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not sale owner.");
        _;
    }

    modifier IsSaleWhitelisted(uint256 _round) {
        require(sale_info[_round].sale_type == 1, "whitelist not set");
        _;
    }

    constructor(
        address owner_,
        address _sale_token,
        uint256[9] memory _sale_details,
        uint256[11] memory _seed_details,
        uint32[5] memory _seed_vesting,
        uint256[11] memory _presale_details,
        uint32[5] memory _presale_vesting,
        uint256[11] memory _community_details,
        uint32[5] memory _community_vesting
    ) {
        owner = msg.sender;

        require(iBlacklist(blacklistContract).getBlacklist(owner_, msg.sender) == 0, 'You are blacklisted!');

        init_sale(
            _sale_token,
            _sale_details,
            _seed_details,
            _seed_vesting,
            _presale_details,
            _presale_vesting,
            _community_details,
            _community_vesting
        );

        owner = owner_;

        emit SaleCreated(owner, address(this));
    }

    function init_sale (
        address _sale_token,
        uint256[9] memory _sale_details,
        uint256[11] memory _seed_details,
        uint32[5] memory _seed_vesting,
        uint256[11] memory _presale_details,
        uint32[5] memory _presale_vesting,
        uint256[11] memory _community_details,
        uint32[5] memory _community_vesting
        ) public onlyOwner {

        require(saleSetting == 0, "Already setted");
        require(_sale_token != address(0), "Zero Address");

        if(_sale_details[0] >= 4) {
            require(_seed_details[7] == 0 && _seed_details[8] == 0 && _presale_details[7] >= block.timestamp && _community_details[7] >= _presale_details[8] && (_presale_details[8] > _presale_details[7] || _community_details[8] > _community_details[7]), "Dates not valid");
        } else if (_sale_details[0] < 4){
            require(_seed_details[7] >= block.timestamp && _seed_details[8] > _seed_details[7] && _presale_details[7] >= _seed_details[8] && _presale_details[8] > _presale_details[7] && _community_details[7] >= _presale_details[8] && _community_details[8] > _community_details[7], "Dates not valid");
        }
        
        sale_details.sale_token = address(_sale_token);
        sale_details.hasSeedRound = 0;
        sale_details.hasPresaleRound = 0;
        sale_details.hasCommunityRound = 0;
        sale_details.listRate = _sale_details[1];
        sale_details.canceled = 0;
        sale_details.saleOption = _sale_details[0];
        sale_details.hasVesting = _sale_details[4];
        sale_details.launchFee = _sale_details[5];
        sale_details.coupon = _sale_details[6];
        sale_details.couponNumber = _sale_details[7];
        sale_details.router = _sale_details[8];

        if(_seed_details[0] > 0) {
            sale_details.hasSeedRound = 1;

            setSaleDetails(1,_seed_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(1, _seed_vesting);
            }
        }

        if(_presale_details[0] > 0) {
            sale_details.hasPresaleRound = 1;

            setSaleDetails(2,_presale_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(2, _presale_vesting);
            }
        }

        if(_community_details[0] > 0) {
            sale_details.hasCommunityRound = 1;

            setSaleDetails(3,_community_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(3, _community_vesting);
            }
        }

        //Set token token info
        tokeninfo.name = ERC20(sale_details.sale_token).name();
        tokeninfo.symbol = ERC20(sale_details.sale_token).symbol();
        tokeninfo.decimal = ERC20(sale_details.sale_token).decimals();
        tokeninfo.totalsupply = ERC20(sale_details.sale_token).totalSupply();

        saleSetting = 1;

    }

    function setSaleDetails(uint256 _sale_round, uint256[11] memory _sale_input) private {
        SaleInfo storage saleInfo = sale_info[_sale_round];

        saleInfo.token_rate = _sale_input[0];
        saleInfo.raise_min = _sale_input[1];
        saleInfo.raise_max = _sale_input[2];
        saleInfo.softcap = _sale_input[3];
        saleInfo.hardcap = _sale_input[4];
        saleInfo.liquidity = _sale_input[5];
        saleInfo.liquidityLock = _sale_input[6];
        saleInfo.start = _sale_input[7];
        saleInfo.end = _sale_input[8];
        saleInfo.mult = _sale_input[9];
        saleInfo.multT = _sale_input[10];
        saleInfo.sale_type = sale_details.saleOption;
        
        saleInfo.attempt = 1;

        saleInfo.liquidityTokens = saleInfo.hardcap * saleInfo.mult / 10000 * sale_details.listRate * saleInfo.liquidity / 100;
    }

    function setSaleVesting(uint256 _sale_round, uint32[5] memory _sale_vesting) private {
        SaleVesting storage saleVesting = sale_vesting[_sale_round];

        saleVesting.TGE = _sale_vesting[0];
        saleVesting.TGE_amount = _sale_vesting[1];
        saleVesting.cliff = _sale_vesting[2];
        saleVesting.period = _sale_vesting[3];
        saleVesting.period_amount = _sale_vesting[4];
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function saleStatusCheck(uint256 _round) public view returns (uint256) {
        if(sale_info[_round].token_rate == 0) { 
            return 0; // Round does not exist
        }
        if(sale_details.canceled == 1) {
            return 4; // Canceled
        }
        if ((block.timestamp > sale_info[_round].end) && (sale_status[_round].sale_raised_amount < sale_info[_round].softcap)) {
            return 3; // Failure
        }
        if (sale_status[_round].sale_raised_amount >= sale_info[_round].hardcap) {
            return 2; // Wonderful - reached to Hardcap
        }
        if ((block.timestamp > sale_info[_round].end) && (sale_status[_round].sale_raised_amount >= sale_info[_round].softcap)) {
            return 2; // SUCCESS - sale ended with reaching Softcap
        }
        if ((block.timestamp >= sale_info[_round].start) && (block.timestamp <= sale_info[_round].end)) {
            return 1; // ACTIVE - Deposits enabled, now in sale
        }
            return 0; // QUED - Awaiting start block
    }

    function saleStatusCheckAll(uint256 _round) public view returns (uint256) { 
        if (_round >= 2) {
            if(saleStatusCheck(1) > 2) {
                return saleStatusCheck(1);
            } 
        }

        if (_round == 3) {
            if(saleStatusCheck(2) > 2) {
                return saleStatusCheck(2);
            }
        }

        return saleStatusCheck(_round);
    }

    function setSaleStatus(uint256 _saleStatus, uint256 _round) public nonReentrant {
        require(msg.sender == admin, 'You are not the admin!');
        if (_saleStatus == 3) {
            sale_info[_round].end == block.timestamp;
        }
    }

    // Accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit (uint256 _round) public payable nonReentrant {
        require(iBlacklist(blacklistContract).getBlacklist(_address, _contract) == 0, 'You are blacklisted!');
        require(saleStatusCheckAll(_round) == 1, "Not Active");

        if(sale_info[_round].sale_type == 1) {
            require(saleWhitelistInfo[msg.sender] == 1, "You are not whitelisted.");
        }
        require(sale_info[_round].raise_min <= msg.value, "Balance is insufficent");
        require(sale_info[_round].raise_max >= msg.value, "Balance is too much");

        BuyerInfo storage buyer = buyers[_round][msg.sender];
        SaleStatus storage saleStatus = sale_status[_round];

        uint256 amount_in = msg.value;
        uint256 allowance = sale_info[_round].raise_max - buyer.sale_base;
        uint256 remaining = sale_info[_round].hardcap - sale_status[_round].sale_raised_amount;

        allowance = allowance > remaining ? remaining : allowance;
        if (amount_in > allowance) {
            amount_in = allowance;
        }

        uint256 tokensSold = amount_in * sale_info[_round].token_rate;

        require(tokensSold > 0, "ZERO TOKENS");
        require(sale_status[_round].sale_raised_amount * sale_info[_round].token_rate <= ERC20(sale_details.sale_token).balanceOf(address(this)), "Token remain error");

        if (buyer.sale_base == 0) {
            sale_status[_round].sale_num_buyers++;
        }
        buyer.sale_base = buyer.sale_base + amount_in;
        buyer.sale = buyer.sale + tokensSold;
        buyer.last_deposit = block.timestamp;
        buyer.TGE_claimable = buyer.TGE_claimable + (tokensSold * sale_vesting[_round].TGE_amount / 100);
        buyer.claimable = buyer.claimable + (tokensSold - buyer.TGE_claimable);
        saleStatus.sale_raised_amount = sale_status[_round].sale_raised_amount + amount_in;
        saleStatus.sale_sold_amount = sale_status[_round].sale_sold_amount + tokensSold;

        // return unused ETH
        if (amount_in < msg.value) {
            payable(msg.sender).transfer(msg.value - amount_in);
        }
         
        emit UserDepsitedSuccess(msg.sender, msg.value);
    }

    // withdraw sale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens (uint256 _round) public nonReentrant {

        // sale withdrawl tokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success
                BuyerInfo storage buyer = buyers[_round][msg.sender];
                SaleStatus storage saleStatus = sale_status[_round];

                uint256 remaintoken = saleStatus.sale_sold_amount - saleStatus.sale_token_withdraw;
                require(remaintoken >= buyer.sale, "Nothing to withdraw.");

                if(sale_details.hasVesting == 0) {
                    require(block.timestamp >= sale_info[_round].end + sale_lock_delay, "Token Locked."); // Lock duration check
                    TransferHelper.safeTransfer(address(sale_details.sale_token), msg.sender, buyer.sale);

                    saleStatus.sale_token_withdraw = saleStatus.sale_token_withdraw + buyer.sale;

                    buyer.claimed = buyer.sale;
                    buyer.sale = 0;
                    buyer.sale_base = 0;
                    buyer.claimable = 0;

                    emit UserWithdrawTokensSuccess(buyer.sale);
                } else {
                    require(block.timestamp >= sale_vesting[_round].TGE, "Token locked");

                    uint256 tge_claim_amount = 0;
                    uint256 claim_amount = 0;

                    if(buyer.TGE_claimed == 0) {
                        tge_claim_amount = tge_claim_amount + (buyer.sale * sale_vesting[_round].TGE_amount / 100);

                        if(tge_claim_amount > buyer.TGE_claimable) {
                            tge_claim_amount = buyer.TGE_claimable;
                        } else {
                            tge_claim_amount = tge_claim_amount - buyer.TGE_claimed;
                        }
                    }

                    if(block.timestamp >= sale_vesting[_round].cliff){
                        claim_amount = claim_amount + (buyer.sale * (sale_vesting[_round].period_amount * ((block.timestamp - sale_vesting[_round].cliff) / sale_vesting[_round].period)) / 100);

                        if(claim_amount > buyer.claimable) {
                            claim_amount = buyer.claimable;
                        } else {
                            claim_amount = claim_amount - buyer.claimable;
                        }
                    }

                    TransferHelper.safeTransfer(address(sale_details.sale_token), msg.sender, (tge_claim_amount + claim_amount));
                    saleStatus.sale_token_withdraw = saleStatus.sale_token_withdraw + tge_claim_amount + claim_amount;

                    buyer.claimed = buyer.claimed + claim_amount;
                    buyer.TGE_claimed = buyer.TGE_claimed + tge_claim_amount;
                    buyer.claimable = buyer.claimable - claim_amount;
                    buyer.TGE_claimable = buyer.TGE_claimable - tge_claim_amount;

                    if(buyer.claimable == 0) {
                        buyer.sale = 0;
                        buyer.sale_base = 0;
                    }

                    emit UserWithdrawTokensVestingSuccess(buyer.TGE_claimed, buyer.claimed);
                }
            }
        }
    }

    // On sale failure
    // Percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens (uint256 _round) public nonReentrant {

        //sale userWithdrawBaseTokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                // Refund
                BuyerInfo storage buyer = buyers[_round][msg.sender];
                require(saleStatusCheck(_round) == 3 || (sale_info[_round].attempt > 1 && buyer.last_deposit < sale_info[_round].start), "Not eligible for withdraw"); // FAILED

                SaleStatus storage saleStatus = sale_status[_round];

                uint256 remainingBaseBalance = address(this).balance;

                require(remainingBaseBalance >= buyer.sale_base, "Nothing to withdraw.");

                saleStatus.sale_base_withdraw = saleStatus.sale_base_withdraw + buyer.sale_base;

                address payable receiver = payable(msg.sender);
                receiver.transfer(buyer.sale_base);

                if(msg.sender == owner) {
                    ownerWithdrawTokens(_round);
                    // return;
                }

                buyer.sale_base = 0;
                buyer.sale = 0;


                emit UserWithdrawSuccess(buyer.sale_base);
            }
        }
    }

    // On sale failure
    function ownerWithdrawTokens (uint256 _round) private onlyOwner {

        // sale ownerWithdrawTokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatusCheck(_round) == 3, "Only failed status."); // FAILED
                TransferHelper.safeTransfer(address(sale_details.sale_token), owner, ERC20(sale_details.sale_token).balanceOf(address(this)));

                emit UserWithdrawSuccess(ERC20(sale_details.sale_token).balanceOf(address(this)));
            }
        }
    }

    function finalizeSale (uint256 _round) public nonReentrant {
        require(msg.sender == owner || msg.sender == admin, "You don't have authorization for this");

        // sale purchaseICOCoin
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success

                address payable receiver = payable(msg.sender);
                receiver.transfer(address(this).balance * sale_info[_round].mult / 10000);

                address payable receiverFee = payable(feeAddress);
                receiverFee.transfer(address(this).balance);

                if(sale_info[_round].multT < 10000) {
                   ERC20(sale_details.sale_token).transferFrom(address(this), address(feeAddress), ((sale_status[_round].sale_sold_amount * (10000 - sale_info[_round].multT)) / 10000));
                }
            }
        }
    }

    function getTimestamp () public view returns (uint256) {
        return block.timestamp;
    }

    function setLockDelay (uint256 delay) public onlyOwner {
        sale_lock_delay = delay;
    }

    function remainingBurn(uint256 _round) public onlyOwner {

        // sale remainingBurn
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success
                require(sale_info[_round].hardcap * sale_info[_round].token_rate >= sale_status[_round].sale_sold_amount, "Nothing to burn");

                uint256 rushTokenAmount = (sale_info[_round].hardcap * sale_info[_round].token_rate) - sale_status[_round].sale_sold_amount;

                TransferHelper.safeTransfer(address(sale_details.sale_token), address(deadaddr), rushTokenAmount);
            }
        }
    }

    function setSaleWhitelist(uint256 _round) public onlyOwner {
        sale_info[_round].sale_type = 1;
    }

    function _addSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 1;
    }

    function _deleteSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 0;
    }

    function setSaleWhitelistInfo(uint256 _round, address[] memory user) public onlyOwner IsSaleWhitelisted(_round) {
        for(uint256 i = 0 ; i < user.length ; i ++) {
            _addSaleWhitelistAddr(user[i]);
        }
    }

    function deleteSaleWhitelistInfo(uint256 _round, address[] memory user) public onlyOwner IsSaleWhitelisted(_round) {
        for(uint256 i = 0 ; i < user.length ; i ++) {
            _deleteSaleWhitelistAddr(user[i]);
        }
    }

    function setSalePublic(uint256 _round) public onlyOwner  {
        sale_info[_round].sale_type = 0;
    }

    function setSaleCancel() public onlyOwner {
        sale_details.canceled = 1;
    }

    function getSaleSaleType (uint256 _round) public view returns (bool) {
        if(sale_info[_round].sale_type == 0) {
            return true;
        } else {
            return false;
        }
    }

    function getSaleStatus (uint256 _round) public view returns (uint256, uint256) {
        return (sale_info[_round].start, sale_info[_round].end);
    }

    function changeAdmin (address newAdmin) public {
        require(msg.sender == admin, "You are not the admin");
        admin = newAdmin;
    }

    function setNewBlacklist(address _newBlacklist) public {
        require(msg.sender == admin, 'You are not the admin!');
        blacklistContract = _newBlacklist;
    }

    function setNewAuditorContract(address _newAuditor) public  {
        require(msg.sender == admin, 'You are not the admin!');
        auditorContract = _newAuditor;
    }

    function changeRaiseAmountAdmin(uint256 _round, uint256 _min, uint256 _max) public {
        require(msg.sender == admin, 'You are not the admin!');
    
        sale_info[_round].raise_min = _min;
        sale_info[_round].raise_max = _max;
    }

    function changeDateAdmin(uint256 _round, uint256 _start, uint256 _end) public {
        require(msg.sender == admin, 'You are not the admin!');
        require(_start > block.timestamp, "Start has to be greater than now");
        require(_end > _start, "End date has to be greater than the start");

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;
    }

    function changeVestingAdmin(uint256 _round, uint256[] memory _vesting) public {
        require(msg.sender == admin, 'You are not the admin!');
        require(sale_vesting[_round].TGE > sale_info[_round].end, "Vesting has to start after the round has finished");
        require(sale_vesting[_round].cliff > sale_info[_round].end, "Vesting has to start after the round has finished");
        require(sale_vesting[_round].cliff >= sale_vesting[_round].TGE, "Cliff has to be greater than or equal to the TGE");

        sale_vesting[_round].TGE = _vesting[0];
        sale_vesting[_round].TGE_amount = _vesting[1];
        sale_vesting[_round].cliff = _vesting[2];
        sale_vesting[_round].period = _vesting[3];
        sale_vesting[_round].period_amount = _vesting[4];
    }

    function restartRound(uint256 _round, uint256 _start, uint256 _end) public payable onlyOwner {
        require(block.timestamp > sale_info[_round].end, "Round has not ended, can't restart");
        require(saleStatusCheckAll(_round) == 3, "Not failed.");
        require(_start > block.timestamp, "Start has to be greater than now");
        require(_end > _start, "End date has to be greater than the start");
        require(_round == 3 || (_end < sale_info[_round + 1].start), "Need to change the next round's dates first");

        uint256 restartFee = sale_details.coupon >= 50 ? sale_details.launchFee * (100 - sale_details.coupon) / 100 : sale_details.launchFee * 75 / 100;

        payable(admin).transfer(restartFee);

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;
        sale_info[_round].attempt = sale_info[_round].attempt + 1;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
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