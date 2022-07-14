/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: None

// created by Coinbird.

pragma solidity ^0.8.15;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Ownable is Context {
    address private _owner;
    bool private noncallable;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        require(noncallable != true);
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        noncallable = true;
    }
}

contract ERC20 is Context, IERC20, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        _approve(owner, spender, currentAllowance - amount);
        }
    }

    bool private mintnoncallable;

    function mintDestructed() public view returns(bool)
    {
        return mintnoncallable;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(mintnoncallable != true, "reverted");
        mintnoncallable = true;
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    address private constant BIRD = 0x23d34579f997b26513D58766eca2C9866ccF1940; //add address
    address private constant HEART = 0xad028683316106E02Be47fCe3982a059517d2A57; //replace with contract

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(excludedFromReward(from) != true){claimReward(from);}
        if(excludedFromReward(to) != true){claimReward(to);}

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
   
        _balances[from] = fromBalance - amount;

        if(to != readUniSwapper()) {
            require((_balances[to]+amount) <= (ANTIWHALElimit*totalSupply()/10000));
        }

        if(from != readUniSwapper()) {
            require(amount <= (ANTIRUGlimit*totalSupply()/10000));
        }

        if((excludedFromTax(to) != true)||(excludedFromTax(from) != true)) {
            REWARDreroute(amount, from);
            CASHBACKreroute(amount, from);
            BIRDreroute(amount, from);
            RAFFLEreroute(amount, from);
            HEARTreroute(amount, from);
        }

        if((Raffler[to] == false)&&(_balances[to] >= RaffleEntryValue)&&(excludedFromReward(from) == true)&&(excludedFromReward(to) != true)) {
            Raffler[to] = true;
            RaffleGeese.push(to);
        }

        if((cashbackenabled == true)&&(excludedFromReward(to) != true)&&(excludedFromReward(from) == true))
        {
            cashback(to, amount);
        }

        _balances[to] += amount*nonrerouted;

        startPot[from] = _balances[REWARD];
        startPot[to] = _balances[REWARD];
        myTimer[from] = block.timestamp;
        myTimer[to] = block.timestamp;

        emit Transfer(from, to, amount*nonrerouted);
    }












    // raffle source code written by Coinbird - controlled

    uint private factor;
    uint private luckyGeese;
    uint private RaffleEntryValue;
    address[] private RaffleGeese;
    mapping(address => bool) private Raffler;
    address private constant RAFFLE = 0xF9091c9256adBFD3071463e242a5Dd5Aa4d6E75b; // add address

    function RaffleFlock() public view returns (uint) // read th number of currently active Rafflers
    {
        return RaffleGeese.length;
    }

    function RaffleEntry() public view returns (uint) // read the minimum amount necessary to HOLD to take part in the raffles
    {
        return RaffleEntryValue;
    }

    function myRaffleStatus() public view returns (bool) // allows the msg.sender to read whether they are an active raffler or not
    {
        return Raffler[_msgSender()];
    }

    function setRaffleEntry(uint Entry) private onlyOwner() // change the minimum amount necessary for participating in the raffles
    {
        RaffleEntryValue = Entry;
    }

    function prepareRaffle(uint Coinbirdy, uint HONK, uint max) private onlyOwner() // set a random number of winners for the next raffle between 1 and max
    {
        require((max <= RaffleGeese.length)&&(luckyGeese == 0));
        luckyGeese = uint(keccak256(abi.encodePacked(block.difficulty+Coinbirdy, block.timestamp-HONK, msg.sender)))%max+1;
        factor = _balances[RAFFLE]*9/10/luckyGeese; // amount of tokens a winner will earn
    }

    function playRaffle() private onlyOwner()
    {
        require(luckyGeese > 0);
        cashRaffle(); // pay out
        factor = 0;
        uint dummy = _balances[RAFFLE];
        claimReward(BIRD);
        _balances[RAFFLE] = 0;
        _balances[BIRD] += dummy;
        startPot[BIRD] = _balances[REWARD];
        emit Transfer(RAFFLE, BIRD, dummy);
    }

    function cashRaffle() private onlyOwner()
    {
        for(; luckyGeese > 0; luckyGeese--)
        {
            address winner = RaffleGeese[uint(keccak256(abi.encodePacked(block.difficulty+luckyGeese, block.timestamp-luckyGeese*luckyGeese, msg.sender)))%(RaffleGeese.length)];
            claimReward(winner); 
            _balances[RAFFLE] -= factor;
            _balances[winner] += factor;
            startPot[winner] = _balances[REWARD];
            emit Transfer(RAFFLE, winner, factor);
        }
    }

    function RaffleGameCaller(uint option, uint setRaffleEntryValue, uint random1, uint random2, uint max) internal onlyOwner()
    {
        if(option == 1){setRaffleEntry(setRaffleEntryValue);}
        if(option == 2){prepareRaffle(random1, random2, max);}
        if(option == 3){playRaffle();}
    }

    // cashback source code written by coinbird - controlled

    bool private cashbackenabled; // determines whether cashbacks are currently active
    address private constant CASHBACK = 0x2f2859732e7d5E1b15A8F725E7F45FDe092E63d6; // replace with contract

    function cashback(address recipient, uint value) private
    {
        uint extraValue = value*CASHBACKfactor/10000;
        if(_balances[CASHBACK] >= extraValue)
        {
            _balances[CASHBACK] -= extraValue;
            _balances[recipient] += extraValue;
            emit Transfer(CASHBACK, recipient, extraValue);
        }
    }

    function cashbackActive() public view returns(bool) // read whether cashbacks are active or not
    {
        return cashbackenabled;
    }

    function alterCashbackState(uint input) private onlyOwner() // enable or disable cashbacks
    {
        if(input == 1){cashbackenabled = true;}
        if(input == 2){cashbackenabled = false;}
    }





















    // reward source code written by coinbird

    address private constant REWARD = 0xF7aa6566f731033C1Fc4169014F8E33110A66218; // contract
    mapping(address => uint) private startPot;
    mapping(address => uint) private myTimer;
    uint private ResetTimer;
    uint private ResetPot;

    function startPotCheck(address rewarded) private view returns (uint)
    {
        if(myTimer[rewarded] <= ResetTimer){return ResetPot;}
        else{return startPot[rewarded];}
    }

    function myReward(address rewarded) private view returns (uint)
    {
        if(excludedFromReward(rewarded) == true){return 0;}
        uint dummy = (_balances[REWARD]-startPotCheck(rewarded))*_balances[rewarded]/_totalSupply;
        if(_balances[REWARD] >= dummy){return dummy;}
        else{return 0;}
    }

    function claimReward(address rewarded) private
    {
        uint dummy = myReward(rewarded);
        myTimer[rewarded] = block.timestamp;
        _balances[REWARD] -= dummy;
        _balances[rewarded] += dummy;
        startPot[rewarded] = _balances[REWARD];
        emit Transfer(REWARD, rewarded, dummy);
    }

    function enrich(uint option, uint divider) private onlyOwner()
    {
        if(option == 1)
        {
            uint dummy = _balances[REWARD]/divider;
            _burn(REWARD, dummy);
            ResetPot = _balances[REWARD];
            ResetTimer = block.timestamp;
        }
        if(option == 2)
        {
            uint dummy = _balances[REWARD]/divider;
            _balances[REWARD] -= dummy;
            _balances[RAFFLE] += dummy;
            emit Transfer(REWARD, RAFFLE, dummy);
            ResetPot = _balances[REWARD];
            ResetTimer = block.timestamp;
        }
        if(option == 3)
        {
            uint dummy = _balances[REWARD]/divider;
            _balances[REWARD] -= dummy;
            _balances[CASHBACK] += dummy;
            emit Transfer(REWARD, RAFFLE, dummy);
            ResetPot = _balances[REWARD];
            ResetTimer = block.timestamp;
        }
    }

    // BIRDCALLER

    function rest(uint choose, uint cashbackstate, uint option, uint divider) internal onlyOwner()
    {
        if(choose == 1){alterCashbackState(cashbackstate);}
        if(choose == 2){enrich(option, divider);}
    }
































    // TOKEMANAGEMENT - controlled

    mapping(address => bool) private excludedFromTaxCheck;
    mapping(address => bool) private excludedFromRewardCheck;

    address private UniSwapperAddress;

    uint private ANTIWHALElimit;
    uint private ANTIRUGlimit;
    uint private CASHBACKfactor;
    uint private REWARDfactor;
    uint private BIRDfactor;
    uint private RAFFLEfactor;
    uint private HEARTfactor;
    uint private nonrerouted;
    bool private OriginalMarketMakerlocked;

    function modifyToken(uint option, uint value, address OriginalMarketMaker, address trader) internal onlyOwner()
    {
        if(option == 0){UniSwapper(OriginalMarketMaker);}
        if(option == 1){excludedFromTax(trader);}
        if(option == 2){excludeFromReward(trader);}
        if(option == 3){newANTIWHALElimit(value);}
        if(option == 4){newANTIRUGlimit(value);}
        if(option == 5){newREWARDfactor(value);}
        if(option == 6){newCASHBACKfactor(value);}
        if(option == 7){newBIRDfactor(value);}
        if(option == 8){newRAFFLEfactor(value);}
        if(option == 9){newHEARTfactor(value);}
    }

    function newNONREROUTEDfactor() private onlyOwner() // full tax
    {
        nonrerouted = 10000 - CASHBACKfactor - REWARDfactor - BIRDfactor - RAFFLEfactor - HEARTfactor;
    }

    function UniSwapper(address OriginalMarketMaker) private onlyOwner() // Define who the UniSwapper is (can only be done once) - must also exclude from rewards
    {
        require(OriginalMarketMakerlocked != true);
        UniSwapperAddress = OriginalMarketMaker;
        OriginalMarketMakerlocked = true;
    }

    function readUniSwapper() public view returns(address) // read who the UniSwapper is
    {
        return UniSwapperAddress;
    }

    function excludeFromTax(address trader) private onlyOwner() // exclude or include an address in the taxation system
    {
        if(excludedFromTaxCheck[trader] == true){excludedFromTaxCheck[trader] = false;}
        if(excludedFromTaxCheck[trader] == false){excludedFromTaxCheck[trader] = true;}
    }

    function excludedFromTax(address trader) public view returns(bool) // check if an address is excluded from taxation
    {
        return excludedFromTaxCheck[trader];
    }

    function excludeFromReward(address trader) private onlyOwner() // exclude or include an address in the GOOSE Reward system
    {
        if(excludedFromRewardCheck[trader] == true){excludedFromRewardCheck[trader] = false;}
        if(excludedFromRewardCheck[trader] == false){excludedFromRewardCheck[trader] = true;}
    }

    function excludedFromReward(address trader) public view returns(bool) // check if an address is excluded from the GOOSE Reward system
    {
        return excludedFromRewardCheck[trader];
    }

    function newANTIWHALElimit(uint newANTIWHALE) private onlyOwner() // change the antiwhale limit (can only be done by the owner)
    {
        require((newANTIWHALE <= 400)&&(newANTIWHALE >= 10));
        ANTIWHALElimit = newANTIWHALE;
    }

    function newANTIRUGlimit(uint newANTIRUG) private onlyOwner() // change the antirug limit (can only be done by the owner)
    {
        require((newANTIRUG <= 400)&&(newANTIRUG >= 10));
        ANTIRUGlimit = newANTIRUG;
    }

    function newHEARTfactor(uint newHEART) private onlyOwner() // change the HEART tax
    {
        require((newHEART <= 700)&&(newHEART >= 100));
        HEARTfactor = newHEART;
        newNONREROUTEDfactor();
    }

    function newREWARDfactor(uint newREWARD) private onlyOwner() // change the REWARD tax
    {
        require((newREWARD <= 120)&&(newREWARD >= 10));
        REWARDfactor = newREWARD;
        newNONREROUTEDfactor();
    }

    function newRAFFLEfactor(uint newRAFFLE) private onlyOwner() // change the RAFFLE tax
    {
        require(newRAFFLE <= 30);
        RAFFLEfactor = newRAFFLE;
        newNONREROUTEDfactor();
    }

    function newCASHBACKfactor(uint newCASHBACK) private onlyOwner() // change the CASHBACK tax
    {
        require(newCASHBACK <= 30);
        CASHBACKfactor = newCASHBACK;
        newNONREROUTEDfactor();
    }

    function newBIRDfactor(uint newBIRD) private onlyOwner() // change the BIRD tax
    {
        require((newBIRD <= 90)&&(newBIRD >= 20));
        BIRDfactor = newBIRD;
        newNONREROUTEDfactor();
    }

    function REWARDreroute(uint value, address from) private // reroute part of the tokens transfered to the REWARD contract
    {
        uint dummy = value*REWARDfactor/10000;
        _balances[from] -= dummy;
        _balances[REWARD] += dummy;
        emit Transfer(from, REWARD, dummy);
    }

    function CASHBACKreroute(uint value, address from) private // reroute part of the tokens transfered to the CASHBACK contract
    {
        uint dummy = value*CASHBACKfactor/10000;
        _balances[from] -= dummy;
        _balances[CASHBACK] += dummy;
        emit Transfer(from, CASHBACK, dummy);
    }  

    function BIRDreroute(uint value, address from) private // reroute part of the tokens transfered to the BIRD wallet
    {
        uint dummy = value*BIRDfactor/10000;
        _balances[from] -= dummy;
        _balances[BIRD] += dummy;
        emit Transfer(from, BIRD, dummy);
    }  

    function RAFFLEreroute(uint value, address from) private // reroute part of the tokens transfered to the RAFFLE contract
    {
        uint dummy = value*RAFFLEfactor/10000;
        _balances[from] -= dummy;
        _balances[RAFFLE] += dummy;
        emit Transfer(from, RAFFLE, dummy);
    }  

    function HEARTreroute(uint value, address from) private // reroute part of the tokens transfered to the HEART wallet
    {
        uint dummy = value*HEARTfactor/10000;
        _balances[from] -= dummy;
        _balances[HEART] += dummy;
        emit Transfer(from, HEART, dummy);
    }
}

contract Coinbird is ERC20, IERC20Metadata {

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _mint(0x23d34579f997b26513D58766eca2C9866ccF1940, 1000000000000000000000);
        _transferOwnership(0xFe15910E806F1894b85C328c1f78CDA015E443fC); //must not be the contract creator!!!
    }

    function BirdRaffle(uint option, uint setRaffleEntryValue, uint prepareRaffleRandom1, uint prepareRaffleRandom2, uint max) public onlyOwner()
    {
        RaffleGameCaller(option, setRaffleEntryValue, prepareRaffleRandom1, prepareRaffleRandom2, max);
    }

    function Tokenomical(uint option, uint value, address OriginalMarketMaker, address trader) public onlyOwner()
    {
        modifyToken(option, value, OriginalMarketMaker, trader);
    }

    function Reward(uint choose, uint cashbackstate, uint option, uint divider) public onlyOwner()
    {
        rest(choose, cashbackstate, option, divider);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 14;
    }
}