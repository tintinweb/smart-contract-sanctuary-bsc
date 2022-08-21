/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract owned {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract BTCFToken is IERC20,owned {
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply;

    struct ConfigStruct {
        uint256 minTotalSupply;
        uint256 minBalance;
        address  gameAddress;
        address  nodeAddress;
        address  superNodeAddress;
        bool transferOpen;
    }

    ConfigStruct public Config;

    mapping(address=>bool) private whiteList;
    mapping(address=>bool) private blockList;
    mapping(address=>bool) public swapAddressMap;
    mapping(address=>address) public inviteMap;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    struct FeeRateStruct{
        uint40  DestroyRate;
        uint40  SuperNodeRate;
        uint40  NodeRate;
        uint40  LPRate;
        uint40  InviteFirstRate;
        uint40  InviteSecondRate;
        uint40  GameRate;
    }

    FeeRateStruct public buyFeeRate;
    FeeRateStruct public sellFeeRate;

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) {
        name = tokenName;
        symbol = tokenSymbol;

        uint256 initialSupply=1000000;

        totalSupply = initialSupply * 10 ** uint256(decimals);
        Config.minTotalSupply = 99000 * 10 ** uint256(decimals);
        Config.minBalance=1  * 10 ** uint256(decimals) / 1000;

        balanceOf[msg.sender] = totalSupply;
        whiteList[msg.sender]=true;
        emit Transfer(address(0),msg.sender,totalSupply);

        buyFeeRate.DestroyRate=0;
        buyFeeRate.SuperNodeRate=10;
        buyFeeRate.NodeRate=10;
        buyFeeRate.LPRate=20;
        buyFeeRate.InviteFirstRate=5;
        buyFeeRate.InviteSecondRate=5;
        buyFeeRate.GameRate=0;

        sellFeeRate.DestroyRate=30;
        sellFeeRate.SuperNodeRate=10;
        sellFeeRate.NodeRate=10;
        sellFeeRate.LPRate=20;
        sellFeeRate.InviteFirstRate=0;
        sellFeeRate.InviteSecondRate=0;
        sellFeeRate.GameRate=10;

        Config.gameAddress=msg.sender;
        Config.nodeAddress=msg.sender;
        Config.superNodeAddress=msg.sender;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    function setConfig(uint256 minTotalSupply, uint256 minBalance,address nodeAddress,address superNodeAddress,address  gameAddress,bool transferOpen)public onlyOwner{
        Config.minTotalSupply=minTotalSupply;
        Config.minBalance=minBalance;
        Config.nodeAddress=nodeAddress;
        Config.superNodeAddress=superNodeAddress;
        Config.gameAddress=gameAddress;
        Config.transferOpen=transferOpen;
    }

    function setFeeRate(uint40 feeType,uint40  DestroyRate,uint40  SuperNodeRate,uint40  NodeRate,uint40  LPRate,uint40  InviteFirstRate,uint40  InviteSecondRate,uint40  GameRate)public onlyOwner{
        if(feeType==1){
            buyFeeRate.DestroyRate=DestroyRate;
            buyFeeRate.SuperNodeRate=SuperNodeRate;
            buyFeeRate.NodeRate=NodeRate;
            buyFeeRate.LPRate=LPRate;
            buyFeeRate.InviteFirstRate=InviteFirstRate;
            buyFeeRate.InviteSecondRate=InviteSecondRate;
            buyFeeRate.GameRate=GameRate;
        }else{
            sellFeeRate.DestroyRate=DestroyRate;
            sellFeeRate.SuperNodeRate=SuperNodeRate;
            sellFeeRate.NodeRate=NodeRate;
            sellFeeRate.LPRate=LPRate;
            sellFeeRate.InviteFirstRate=InviteFirstRate;
            sellFeeRate.InviteSecondRate=InviteSecondRate;
            sellFeeRate.GameRate=GameRate;
        }
    }


    function setWhiteAddress(address addr,bool status)  onlyOwner public {
        whiteList[addr] = status;
    }

    function setBlockAddress(address addr,bool status)  onlyOwner public {
        blockList[addr] = status;
    }

    function setSwapAddress(address addr,bool status)  onlyOwner public {
        swapAddressMap[addr] = status;
    }

    function transfer(address recipient, uint256 amount) public returns(bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowance[sender][msg.sender]-amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns(bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function withdrawEth(address payable addr, uint256 amount) onlyOwner public{
        addr.transfer(amount);
    }

    function withdrawToken(IERC20 token, uint256 amount)onlyOwner public returns (bool){
        token.transfer(msg.sender, amount);
        return true;
    }

    function _transfer_default(address sender,address recipient,uint256 amount)private{
        balanceOf[sender]=balanceOf[sender]-amount;
        balanceOf[recipient]=balanceOf[recipient]+amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transfer_fee_check(address sender, address recipient)private view returns(FeeRateStruct memory){
        FeeRateStruct memory swapFee ;
        if(swapAddressMap[sender]==true){
            swapFee=buyFeeRate;
        }else if (swapAddressMap[recipient]==true){
            swapFee=sellFeeRate;
        }

        if(totalSupply-balanceOf[deadAddress]<=Config.minTotalSupply){
            swapFee.DestroyRate=0;
        }

        return swapFee;
    }

    event AddSuperNodeAmount(uint256 amount);
    event AddNodeAmount(uint256 amount);

    function _transfer_swap(address sender, address recipient, uint256 amount) private{
        FeeRateStruct memory swapFee =_transfer_fee_check(sender,recipient);
        uint256 feeAmount = 0;

        address fromAddress;
        address thisSwapAddress;
        if(swapAddressMap[sender]){
            fromAddress=recipient;
            thisSwapAddress=sender;
        }else{
            fromAddress=sender;
            thisSwapAddress=recipient;
        }

        address inviteFirst = inviteMap[fromAddress];
        address inviteSecond = inviteMap[inviteFirst];

        if(swapFee.InviteFirstRate>0&&inviteFirst!=address(0)){
            uint256 inviteFirstAmount = amount * swapFee.InviteFirstRate / 1000;
            feeAmount=feeAmount+inviteFirstAmount;
            _transfer_default(sender,inviteFirst,inviteFirstAmount);
        }

        if(swapFee.InviteSecondRate>0&&inviteSecond!=address(0)){
            uint256 inviteSecondAmount = amount * swapFee.InviteSecondRate / 1000;
            feeAmount=feeAmount+inviteSecondAmount;
            _transfer_default(sender,inviteSecond,inviteSecondAmount);
        }

        if(swapFee.GameRate>0){
            uint256 gameAmount = amount * swapFee.GameRate / 1000;
            feeAmount=feeAmount+gameAmount;
            _transfer_default(sender,Config.gameAddress,gameAmount);
        }

        if(swapFee.DestroyRate>0){
            uint256 thisDestroyAmount = amount * swapFee.DestroyRate / 1000;
            feeAmount=feeAmount+thisDestroyAmount;
            _transfer_default(sender,deadAddress,thisDestroyAmount);
        }
        if(swapFee.SuperNodeRate>0){
            uint256 superNodeAmount = amount * swapFee.SuperNodeRate / 1000;
            feeAmount=feeAmount+superNodeAmount;
            _transfer_default(sender,Config.superNodeAddress,superNodeAmount);
            emit AddSuperNodeAmount(superNodeAmount);
        }
        if(swapFee.NodeRate>0){
            uint256 nodeAmount = amount * swapFee.NodeRate / 1000;
            feeAmount=feeAmount+nodeAmount;
            _transfer_default(sender,Config.nodeAddress,nodeAmount);
            emit AddNodeAmount(nodeAmount);
        }
        if(swapFee.LPRate>0){
            uint256 lpAmount = amount * swapFee.LPRate / 1000;
            feeAmount=feeAmount+lpAmount;
            _transfer_default(sender,thisSwapAddress,lpAmount);
        }

        uint256 toBalance = amount - feeAmount;
        _transfer_default(sender,recipient,toBalance);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(blockList[sender]==false,"Blacklist cannot transfer money");
        bindInvite(sender,recipient);

        if (whiteList[sender]||whiteList[recipient]){
            _transfer_default(sender,recipient,amount);
            return;
        }
        require(Config.transferOpen==true,"Trading is not open");

        if (swapAddressMap[sender]==true||swapAddressMap[recipient]==true) {
            _transfer_swap(sender,recipient,amount);
        }else{
            _transfer_default(sender,recipient,amount);
        }
        require(balanceOf[sender]>=Config.minBalance,"not sufficient funds");
    }


    function destroyAmount(uint256 amount)   public {
        uint256 hasTotal = totalSupply-Config.minTotalSupply;
        if (balanceOf[deadAddress]>=hasTotal){
            return;
        }
        if(hasTotal-balanceOf[deadAddress]<amount){
            amount=hasTotal-balanceOf[deadAddress];
        }
        transfer(deadAddress,amount);
    }

    function isContract(address addr)private view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function bindInvite(address from,address to)private {
        if (inviteMap[to]!=address(0) || isContract(from) || isContract(to)){
            return;
        }
        if ( from==to ||to==owner||from==address(0)){
            return;
        }

        inviteMap[to]=from;
    }
}