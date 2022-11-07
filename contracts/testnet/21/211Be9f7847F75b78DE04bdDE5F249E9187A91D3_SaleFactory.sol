// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Sale} from "./SubLevel/Sale.sol";

interface iSaleMaster {
    function _getBlacklist(address _address, address _contract) external view returns (uint256 is_blacklisted);
    function _owner() external returns(address);
}

contract SaleFactory {

  iSaleMaster internal _saleMaster;

  address public _owner;
  address public saleMasterAddress;

  event SaleCreated(address _Owner, address _Token, address _Sale_Address, address _Sale_Vault_Address, address _Incentive_Address,
                    uint256[8] _Sale_Details, uint256[11] _Seed_Details, uint32[5] _Seed_Vesting, uint256[11] _Presale_Details,
                    uint32[5] _Presale_Vesting, uint256[11] _Community_Details, uint32[5] _Community_Vesting);
  event SaleMasterAddressChanged(address _Previous_Sale_Master, address _Sale_Master);
  event OwnerChanged(address _Previous_Owner, address _Owner);

  modifier onlyOwner {
    require(msg.sender == _owner, "Not owner");
    _;
  }

  constructor() {
    _owner = msg.sender;
  }

  function setSaleMasterAddress(address _saleMasterAddress) public onlyOwner {
    address prev_address = saleMasterAddress;

    saleMasterAddress = _saleMasterAddress;
    _saleMaster = iSaleMaster(_saleMasterAddress);

    emit SaleMasterAddressChanged(prev_address, _saleMasterAddress);
  }

  function createSale(
    address[4] memory addresses,
    uint256[8] memory _sale_details,
    uint256[11] memory _seed_details,
    uint32[5] memory _seed_vesting,
    uint256[11] memory _presale_details,
    uint32[5] memory _presale_vesting,
    uint256[11] memory _community_details,
    uint32[5] memory _community_vesting
  ) external returns (address) {
    require(msg.sender == saleMasterAddress, "Not authorized");
    require(_owner == _saleMaster._owner(), "Owners don't align");

    Sale sale = new Sale(
      addresses[0],
      addresses[1],
      addresses[2],
      addresses[3],
      _sale_details,
      _seed_details,
      _seed_vesting,
      _presale_details,
      _presale_vesting,
      _community_details,
      _community_vesting
    );

    emit SaleCreated(addresses[0], addresses[1], address(sale), addresses[2], addresses[3],
                    _sale_details, _seed_details, _seed_vesting, _presale_details, _presale_vesting,
                    _community_details, _community_vesting);

    return (address(sale));
  }

  function setNewOwner(address _newOwner) public onlyOwner {
    address prev_owner = _owner;

    _owner = _newOwner;

    emit OwnerChanged(prev_owner, _newOwner);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }
}

interface iSaleFactory {
    function saleMasterAddress() external returns(address);
}

interface iSaleMaster {
    function _getBlacklist(address _address, address _contract) external view returns (uint256 is_blacklisted);
    function adminAddress() external returns(address);
    function feeAddress() external returns(address);
    function launchFee(uint256 _saleType) external view returns (uint256);
}

interface iSaleVault {
    function createLock(uint8 _round, address _token, uint256 _token_amount, uint256 _weth_amount, uint256 _start, uint256 _end) external payable;
}

interface iIncentive {
    function findWinnerBase(uint256 _round, uint256[3] memory _randoms) external payable;
    function findWinnerToken(uint256 _round, uint256[3] memory _randoms) external;
    function calcPrize(uint256 _round, uint256 _amount_in) external;
    function getType(uint256 _round) external view returns(uint256);
    function getPrizeAmount(uint256 _round) external view returns(uint256);
    function updateDate(uint256 _round, uint256 _newDate) external;
    function setEntrantDetails(uint256 _round, address _entrant, uint256 _amount) external;
}

contract Sale is ReentrancyGuard {
    iSaleFactory immutable _saleFactory;
    iSaleMaster internal _saleMaster;
    iSaleVault immutable _saleVault;
    iIncentive immutable _incentive;

    struct SaleDetails {
        address sale_token;
        uint256 canceled;
        uint256 listRate;
        uint256 saleOption;
        uint256 coupon;
        uint256 hasVesting;
        uint256 hasLiquidity;
        uint256 hasIncentive;
    }

    struct SaleInfo {
        uint256 token_rate;
        uint256 raise_min;
        uint256 raise_max;
        uint256 softcap;
        uint256 hardcap;
        uint256 start;
        uint256 end;
        uint256 liquidity;
        uint256 liquidityLock;
        uint256 sale_type;
        uint256 attempt;
        uint256 mult;
        uint256 multT;
    }

    struct SaleVesting {
        uint256 TGE;
        uint256 TGE_amount;
        uint256 cliff;
        uint256 period;
        uint256 period_amount;
    }

    struct SaleStatus {
        uint256 force_failed;
        uint256 sale_raised_amount;
        uint256 sale_sold_amount;
        uint256 sale_token_withdraw;
        uint256 sale_base_withdraw;
        uint256 sale_num_buyers;
        uint256 sale_finalized;
    }

    struct BuyerInfo {
        uint256 sale_base;
        uint256 sale;
        uint256 last_deposit;
        uint256 TGE_claimable;
        uint256 claimable;
        uint256 TGE_claimed;
        uint256 claimed;
    }

    struct TokenInfo {
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    address public owner;
    address immutable saleFactoryAddress;
    address internal saleMasterAddress;
    address immutable saleVaultAddress;
    address internal incentiveAddress;
    address internal adminAddress;
    address internal feeAddress;
    uint256 immutable launchFee;
    
    SaleDetails internal sale_details;
    mapping(uint256 => SaleInfo) internal sale_info;
    mapping(uint256 => SaleVesting) internal sale_vesting;
    mapping(uint256 => SaleStatus) internal sale_status;
    mapping(uint256 => mapping(address => BuyerInfo)) internal buyers;
    TokenInfo internal tokeninfo;

    uint256 internal ownerWithdraw = 0;
    uint256 immutable convert;

    mapping(address => uint) internal saleWhitelistInfo;

    event SaleCreated(address _Owner, address _Sale_Address);
    event UserDepsitedSuccess(uint256 _Round, address _User, uint256 _Amount);
    event UserWithdrawSuccess(uint256 _Round, address _User, uint256 _Amount);
    event OwnerWithdrawTokenSuccess(uint256 _Round, uint256 _Amount);
    event UserWithdrawTokensSuccess(uint256 _Round, address _User, uint256 _Amount);
    event UserWithdrawTokensVestingSuccess(uint256 _Round, address _User, uint256 _TGE_Amount, uint256 _Amount);
    event SaleFinalized(uint256 _Round, address _Owner, uint256 _Fee, uint256 _Liquidity, uint256 _Incentive, uint256 _Payout);
    event PaymentSent(address _Address, uint256 _Amount);
    event RemainingBurned(uint256 _Round, uint256 _Amount);
    event SaleWhitelisted(uint256 _Round);
    event SalePublic(uint256 _Round);
    event SaleCancelled();
    event ChangedRaiseAmount(uint256 _Round, uint256 _Prev_Min, uint256 _Min, uint256 _Prev_Max, uint256 _Max);
    event ChangedDate(uint256 _Round, uint256 _Prev_Start, uint256 _Start, uint256 _Prev_End, uint256 _End);
    event ChangedVesting(uint256 _Round, uint256[5] _Prev_Vesting, uint256[5] _Vesting);
    event SaleRestarted(uint256 _Round, address _Owner, uint256 _Prev_Start, uint256 _Start, uint256 _Prev_End, uint256 _End, uint256 _Attempt, uint256 _Fee);

    address internal deadaddr = 0x000000000000000000000000000000000000dEaD;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not sale owner.");
        _;
    }

    modifier IsSaleWhitelisted(uint256 _round) {
        require(sale_info[_round].sale_type == 1, "whitelist not set");
        _;
    }

    modifier IsSaleEnded(uint256 _round) {
        require(sale_info[_round].end > 0 && block.timestamp > sale_info[_round].end, "Not ended");
        _;
    }

    constructor(
        address owner_,
        address _sale_token,
        address _sale_vault,
        address _sale_incentive,
        uint256[8] memory _sale_details,
        uint256[11] memory _seed_details,
        uint32[5] memory _seed_vesting,
        uint256[11] memory _presale_details,
        uint32[5] memory _presale_vesting,
        uint256[11] memory _community_details,
        uint32[5] memory _community_vesting
    ) {
        owner = msg.sender;
        saleFactoryAddress = msg.sender;
        
        _saleFactory = iSaleFactory(msg.sender);

        saleMasterAddress = _saleFactory.saleMasterAddress();
        _saleMaster = iSaleMaster(saleMasterAddress);

        saleVaultAddress = _sale_vault;
        _saleVault = iSaleVault(_sale_vault);

        incentiveAddress = _sale_incentive;
        _incentive = iIncentive(incentiveAddress);

        adminAddress = _saleMaster.adminAddress();
        feeAddress = _saleMaster.feeAddress();
        convert = 10 ** ERC20(_sale_token).decimals();
        launchFee = _saleMaster.launchFee(_sale_details[0]);

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
        uint256[8] memory _sale_details,
        uint256[11] memory _seed_details,
        uint32[5] memory _seed_vesting,
        uint256[11] memory _presale_details,
        uint32[5] memory _presale_vesting,
        uint256[11] memory _community_details,
        uint32[5] memory _community_vesting
        ) internal {

        sale_details.sale_token = address(_sale_token);
        sale_details.listRate = _sale_details[1];
        sale_details.canceled = 0;
        sale_details.saleOption = _sale_details[0];
        sale_details.coupon = _sale_details[5];
        sale_details.hasVesting = _sale_details[4];
        sale_details.hasLiquidity = _sale_details[6];
        sale_details.hasIncentive = _sale_details[7];

        if(_seed_details[0] > 0) {
            setSaleDetails(1,_seed_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(1, _seed_vesting);
            }
        }

        if(_presale_details[0] > 0) {
            setSaleDetails(2,_presale_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(2, _presale_vesting);
            }
        }

        if(_community_details[0] > 0) {
            setSaleDetails(3,_community_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(3, _community_vesting);
            }
        }

        tokeninfo.name = ERC20(sale_details.sale_token).name();
        tokeninfo.symbol = ERC20(sale_details.sale_token).symbol();
        tokeninfo.decimal = ERC20(sale_details.sale_token).decimals();
        tokeninfo.totalsupply = ERC20(sale_details.sale_token).totalSupply();

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
        saleInfo.sale_type = 0;
        saleInfo.attempt = 1;
    }

    function setSaleVesting(uint256 _sale_round, uint32[5] memory _sale_vesting) private {
        SaleVesting storage saleVesting = sale_vesting[_sale_round];

        saleVesting.TGE = uint256(_sale_vesting[0]);
        saleVesting.TGE_amount = uint256(_sale_vesting[1]);
        saleVesting.cliff = uint256(_sale_vesting[2]);
        saleVesting.period = uint256(_sale_vesting[3]);
        saleVesting.period_amount = uint256(_sale_vesting[4]);
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

        if (_round >= 3) {
            if(saleStatusCheck(2) > 2) {
                return saleStatusCheck(2);
            }
        }

        return saleStatusCheck(_round);
    }

    function setSaleStatus(uint256 _saleStatus, uint256 _round) public nonReentrant {
        require(msg.sender == adminAddress, "Not admin");
        if (_saleStatus == 3) {
            sale_info[_round].end == block.timestamp;
        }
    }

    // Accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit (uint256 _round) public payable nonReentrant {
        require(_saleMaster._getBlacklist(msg.sender, address(this)) == 0, "Blacklisted");
        require(saleStatusCheckAll(_round) == 1, "Not Active");

        if(sale_info[_round].sale_type == 1) {
            require(saleWhitelistInfo[msg.sender] == 1, "Not whitelisted.");
        }
        require(sale_info[_round].raise_min <= msg.value, "Insufficent balance");
        require(sale_info[_round].raise_max >= msg.value, "Balance is too much");

        BuyerInfo storage buyer = buyers[_round][msg.sender];
        SaleStatus storage saleStatus = sale_status[_round];

        uint256 amount_in = msg.value;
        uint256 allowance = sale_info[_round].raise_max - buyer.sale_base;
        uint256 remaining = sale_info[_round].hardcap - saleStatus.sale_raised_amount;
        uint256 token_rate = sale_info[_round].token_rate / convert;

        allowance = allowance > remaining ? remaining : allowance;
        if (amount_in > allowance) {
            amount_in = allowance;
        }

        uint256 tokensSold = amount_in * token_rate;

        require(tokensSold > 0, "ZERO TOKENS");
        require(tokensSold <= ERC20(sale_details.sale_token).balanceOf(address(this)), "Token remain error");

        if (buyer.sale_base == 0) {
            saleStatus.sale_num_buyers++;
        }
        buyer.sale_base = buyer.sale_base + amount_in;
        buyer.sale = buyer.sale + tokensSold;
        buyer.last_deposit = block.timestamp;
        buyer.TGE_claimable = buyer.TGE_claimable + (tokensSold * sale_vesting[_round].TGE_amount / 100);
        buyer.claimable = buyer.claimable + (tokensSold - (tokensSold * sale_vesting[_round].TGE_amount / 100));
        saleStatus.sale_raised_amount = saleStatus.sale_raised_amount + amount_in;
        saleStatus.sale_sold_amount = saleStatus.sale_sold_amount + tokensSold;

        if(sale_details.hasIncentive == 1) {
            _incentive.setEntrantDetails(_round, msg.sender, amount_in);
        }

        // return unused ETH
        if (amount_in < msg.value) {
            payout(msg.sender,msg.value - amount_in);
        }
         
        emit UserDepsitedSuccess(_round, msg.sender, msg.value);
    }

    // withdraw sale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens (uint256 _round) public nonReentrant IsSaleEnded(_round) {
        require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success
        BuyerInfo storage buyer = buyers[_round][msg.sender];
        SaleStatus storage saleStatus = sale_status[_round];

        uint256 remaintoken = saleStatus.sale_sold_amount - saleStatus.sale_token_withdraw;
        require(remaintoken >= (buyer.TGE_claimable + buyer.claimable), "Nothing to withdraw.");

        if(sale_details.hasVesting == 0) {
            require(block.timestamp >= sale_info[_round].end, "Token Locked."); // Lock duration check
            TransferHelper.safeTransfer(address(sale_details.sale_token), msg.sender, buyer.sale);

            saleStatus.sale_token_withdraw = saleStatus.sale_token_withdraw + buyer.sale;

            buyer.claimed = buyer.sale;
            buyer.sale = 0;
            buyer.sale_base = 0;
            buyer.claimable = 0;

            emit UserWithdrawTokensSuccess(_round, msg.sender, buyer.sale);
        } else {
            require(block.timestamp >= sale_vesting[_round].TGE, "Token locked");

            uint256 tge_claim_amount = 0;
            uint256 claim_amount = 0;

            if(buyer.TGE_claimed == 0) {
                tge_claim_amount = (buyer.sale * sale_vesting[_round].TGE_amount / 100) - buyer.TGE_claimed;

                if(tge_claim_amount > buyer.TGE_claimable) {
                    tge_claim_amount = buyer.TGE_claimable;
                } 
            }

            uint256 cliffDate = (sale_vesting[_round].cliff == 0) ? (sale_vesting[_round].TGE + sale_vesting[_round].period) : sale_vesting[_round].cliff;

            if(block.timestamp >= cliffDate){

                claim_amount = (buyer.sale * (sale_vesting[_round].period_amount * (((block.timestamp - cliffDate) / sale_vesting[_round].period) + 1)) / 100) - buyer.claimed;

                if(claim_amount > buyer.claimable) {
                    claim_amount = buyer.claimable;
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

            emit UserWithdrawTokensVestingSuccess(_round, msg.sender, buyer.TGE_claimed, buyer.claimed);
        }
    }

    // On sale failure
    // Percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens (uint256 _round) public nonReentrant IsSaleEnded(_round) {
        BuyerInfo storage buyer = buyers[_round][msg.sender];
        require(saleStatusCheck(_round) >= 3 || (sale_info[_round].attempt > 1 && buyer.last_deposit < sale_info[_round].start), "Not eligible"); // FAILED

        SaleStatus storage saleStatus = sale_status[_round];

        uint256 remainingBaseBalance = address(this).balance;

        require(remainingBaseBalance >= buyer.sale_base, "No withdraw.");

        saleStatus.sale_base_withdraw = saleStatus.sale_base_withdraw + buyer.sale_base;

        payout(msg.sender,buyer.sale_base);

        if(msg.sender == owner) {
            ownerWithdrawTokens(_round);
        }

        buyer.sale_base = 0;
        buyer.sale = 0;


        emit UserWithdrawSuccess(_round, msg.sender, buyer.sale_base);
    }

    // On sale failure
    function ownerWithdrawTokens (uint256 _round) private onlyOwner IsSaleEnded(_round) {
        require(saleStatusCheck(_round) >= 3, "Not failed"); // FAILED
        TransferHelper.safeTransfer(address(sale_details.sale_token), owner, ERC20(sale_details.sale_token).balanceOf(address(this)));

        ownerWithdraw = 1;

        emit OwnerWithdrawTokenSuccess(_round, ERC20(sale_details.sale_token).balanceOf(address(this)));
    }

    function finalizeSale (uint8 _round, uint256[3] memory _randoms) public nonReentrant IsSaleEnded(_round) {
        require(msg.sender == owner || msg.sender == adminAddress, "Final auth");
        require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success
        require(sale_status[_round].sale_finalized == 0, "Finalized");

        uint256[3] memory payAmounts = [uint256(0),0,0];
        
        // Calculate the fee
        payAmounts[0] = ((sale_status[_round].sale_raised_amount * (10000 - sale_info[_round].mult)) / 10000);

        // Calculate the liquidity amount
        payAmounts[1] = (sale_status[_round].sale_raised_amount * sale_info[_round].mult / 10000 * sale_info[_round].liquidity / 100);
        uint256 liquidityToken = (sale_status[_round].sale_raised_amount * sale_info[_round].mult / 10000 * sale_details.listRate / convert * sale_info[_round].liquidity / 100);
        
        // Fee collection
        if(payAmounts[0] > 0) {
            payout(feeAddress,payAmounts[1]);
        }

        if(sale_info[_round].multT < 10000) {
            ERC20(sale_details.sale_token).transfer(address(feeAddress), ((sale_status[_round].sale_sold_amount * (10000 - sale_info[_round].multT)) / 10000));
        }

        // Liquidity lock
        if(payAmounts[1] > 0) {
            ERC20(sale_details.sale_token).transfer(address(saleVaultAddress), liquidityToken);
            _saleVault.createLock{value:payAmounts[1]}(_round, sale_details.sale_token, liquidityToken, payAmounts[1], sale_info[_round].end, sale_info[_round].end + (sale_info[_round].liquidityLock * 1 minutes));
        }

        // Incentive calculation and payout
        if(_incentive.getType(_round) == 1) {
            _incentive.calcPrize(_round, sale_status[_round].sale_sold_amount);
            ERC20(sale_details.sale_token).transfer(address(incentiveAddress), _incentive.getPrizeAmount(_round));
            _incentive.findWinnerToken(_round, _randoms);
        } else if(_incentive.getType(_round) == 2) {
            _incentive.calcPrize(_round, sale_status[_round].sale_raised_amount);
            _incentive.findWinnerBase{value:_incentive.getPrizeAmount(_round)}(_round, _randoms);
            payAmounts[2] = _incentive.getPrizeAmount(_round);
        }
        
        // Payout to owner their remaining share
        payout(msg.sender,sale_status[_round].sale_raised_amount - payAmounts[0] - payAmounts[1] - payAmounts[2]);

        setSaleFinalized(_round);

        emit SaleFinalized(_round, msg.sender, payAmounts[0], payAmounts[1], payAmounts[2], sale_status[_round].sale_raised_amount - payAmounts[0] - payAmounts[1] - payAmounts[2]);
    }

    function payout(address _address, uint256 _amount) internal {
        payable(_address).transfer(_amount);

        emit PaymentSent(_address, _amount);
    }

    function setSaleFinalized(uint256 _round) internal {
        SaleStatus storage saleStatus = sale_status[_round];
        saleStatus.sale_finalized = 1;
    }

    function remainingBurn(uint256 _round) public onlyOwner IsSaleEnded(_round) {
        require(saleStatusCheck(_round) == 2, "Not succeeded"); // Success

        uint256 token_rate = sale_info[_round].token_rate / convert;

        require(sale_info[_round].hardcap * token_rate >= sale_status[_round].sale_sold_amount, "Nothing to burn");

        uint256 rushTokenAmount = (sale_info[_round].hardcap * token_rate) - sale_status[_round].sale_sold_amount;

        TransferHelper.safeTransfer(address(sale_details.sale_token), address(deadaddr), rushTokenAmount);

        emit RemainingBurned(_round, rushTokenAmount);
    }

    function setSaleWhitelist(uint256 _round) public onlyOwner {
        sale_info[_round].sale_type = 1;

        emit SaleWhitelisted(_round);
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
        require(ownerWithdraw == 0, "Tokens removed");
        sale_info[_round].sale_type = 0;

        emit SalePublic(_round);
    }

    function setSaleCancel() public onlyOwner {
        require(saleStatusCheck(1) < 2 && saleStatusCheck(2) < 2 && saleStatusCheck(3) < 2, "Cannot cancel");
        sale_details.canceled = 1;

        emit SaleCancelled();
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

    function getBuyerInfo(uint256 _round, address _buyer) public view returns (uint256 sale_base,uint256 sale,uint256 last_deposit,uint256 TGE_claimable,uint256 claimable,uint256 TGE_claimed,uint256 claimed) {
        BuyerInfo memory buyer = buyers[_round][_buyer];

        return(
            buyer.sale_base,
            buyer.sale,
            buyer.last_deposit,
            buyer.TGE_claimable,
            buyer.claimable,
            buyer.TGE_claimed,
            buyer.claimed
        );
    }

    function getSaleStatusInfo(uint256 _round) public view returns (uint256 force_failed,uint256 sale_raised_amount,uint256 sale_sold_amount,uint256 sale_token_withdraw,uint256 sale_base_withdraw,uint256 sale_num_buyers) {
        SaleStatus memory saleStatus = sale_status[_round];

        return(
            saleStatus.force_failed,
            saleStatus.sale_raised_amount,
            saleStatus.sale_sold_amount,
            saleStatus.sale_token_withdraw,
            saleStatus.sale_base_withdraw,
            saleStatus.sale_num_buyers
        );
    }

    function getSaleRaiseInfo(uint256 _round) public view returns (uint256 raise_min,uint256 raise_max,uint256 softcap,uint256 hardcap) {
        SaleInfo memory saleInfo = sale_info[_round];

        return(saleInfo.raise_min,saleInfo.raise_max,saleInfo.softcap,saleInfo.hardcap);
    }

    function syncData() public {
        require(msg.sender == owner || msg.sender == adminAddress, "Not authorized");
        adminAddress = _saleMaster.adminAddress();
        feeAddress = _saleMaster.feeAddress();
    } 

    function setSaleMaster(address _newAddress) public {
        require(msg.sender == adminAddress, "Not authorized");
        saleMasterAddress = _newAddress;
        _saleMaster = iSaleMaster(saleMasterAddress);
    } 

    function changeRaiseAmountAdmin(uint256 _round, uint256 _min, uint256 _max) public {
        require(msg.sender == adminAddress, "Not admin");
    
        uint256 prev_min = sale_info[_round].raise_min;
        uint256 prev_max = sale_info[_round].raise_max;

        sale_info[_round].raise_min = _min;
        sale_info[_round].raise_max = _max;

        emit ChangedRaiseAmount(_round, prev_min, _min, prev_max, _max);
    }

    function changeDateAdmin(uint256 _round, uint256 _start, uint256 _end) public {
        require(msg.sender == adminAddress, "Not admin");
        
        uint256 prev_start = sale_info[_round].start;
        uint256 prev_end = sale_info[_round].end;

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;

        if(sale_details.hasIncentive == 1 && _incentive.getType(_round) > 0) {
            _incentive.updateDate(_round, _end);           
        }

        emit ChangedDate(_round, prev_start, _start, prev_end, _end);
    }

    function changeVestingAdmin(uint256 _round, uint256[5] memory _vesting) public {
        require(msg.sender == adminAddress, "Not admin");
        
        uint256[5] memory prev_vesting = [sale_vesting[_round].TGE, sale_vesting[_round].TGE_amount, sale_vesting[_round].cliff, sale_vesting[_round].period, sale_vesting[_round].period_amount];

        sale_vesting[_round].TGE = _vesting[0];
        sale_vesting[_round].TGE_amount = _vesting[1];
        sale_vesting[_round].cliff = _vesting[2];
        sale_vesting[_round].period = _vesting[3];
        sale_vesting[_round].period_amount = _vesting[4];

        emit ChangedVesting(_round, prev_vesting, _vesting);
    }

    function restartRound(uint256 _round, uint256 _start, uint256 _end) public payable onlyOwner {
        require(block.timestamp > sale_info[_round].end, "Round not ended");
        require(saleStatusCheckAll(_round) >= 3, "Not failed.");
        require(_start > block.timestamp, "Start date wrong");
        require(_end > _start, "End date wrong");
        require(_round >= 3 || (_end < sale_info[_round + 1].start), "Change dates first");
        require(ownerWithdraw == 0, "Tokens removed");

        uint256 restartFee = sale_details.coupon >= 50 ? launchFee * (100 - sale_details.coupon) / 100 : launchFee * 75 / 100;

        payout(adminAddress,restartFee);

        uint256[2] memory prev_dates = [sale_info[_round].start,sale_info[_round].end];

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;
        sale_info[_round].attempt = sale_info[_round].attempt + 1;

        if(sale_details.hasIncentive == 1 && _incentive.getType(_round) > 0) {
            _incentive.updateDate(_round, _end);           
        }

        emit SaleRestarted(_round, msg.sender, prev_dates[0], _start, prev_dates[1], _end, sale_info[_round].attempt, restartFee);
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