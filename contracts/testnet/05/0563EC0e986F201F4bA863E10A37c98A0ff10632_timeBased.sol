/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.12;

contract timeBased {

    mapping(address => bool) internal HolderAssociate;
    mapping(address => bool) internal TraderAssociate;
    mapping(address => uint256) internal expiryHolder;
    mapping(address => uint256) internal expiryTrader;

    address[] internal isAssociateHolder;
    address[] internal isAssociateTrader;

    uint256 internal holderTimer;
    uint256 internal traderTimer;
    uint256 internal holderBNB;
    uint256 internal traderBNB;

    event titleValues        (address indexed sender, uint256 indexed _holderBNB, uint256 indexed _traderBNB);
    event associateTime      (address indexed sender, uint256 indexed _holderTimer, uint256 indexed _traderTimer);
    event holderAssociate    (address indexed account, uint256 indexed value);
    event traderAssociate    (address indexed account, uint256 indexed value);
    event ExclueAssociate    (address indexed account);

    modifier laserTimer(address _account) {
    if (expiryHolder[_account] >= block.timestamp){
            expiryHolder[_account] = 0;
            HolderAssociate[_account] = false;
        for (uint256 i = 0; i < isAssociateHolder.length; i++) {
            if (isAssociateHolder[i] == _account) {
                isAssociateHolder[i] = isAssociateHolder[isAssociateHolder.length - 1];
                emit ExclueAssociate(_account);
                isAssociateHolder.pop();
                break;
            }
        }}
    if (expiryTrader[_account] >= block.timestamp){
            expiryTrader[_account] = 0;
            TraderAssociate[_account] = false;
        for (uint256 i = 0; i < isAssociateTrader.length; i++) {
            if (isAssociateTrader[i] == _account) {
                isAssociateTrader[i] = isAssociateTrader[isAssociateHolder.length - 1];
                emit ExclueAssociate(_account);
                isAssociateTrader.pop();
                break;
            }
        }}
        _;
    }

constructor() public payable {}

    function associates() public view returns(uint256 Holder_associate, uint256 Trader_associate){
        Holder_associate = isAssociateHolder.length;
        Trader_associate = isAssociateTrader.length;
    return (Holder_associate, Trader_associate);
    }

    function title_Values() public view returns (uint256 Holder_BNBvalue, uint256 Trader_BNBvalue){
        Holder_BNBvalue = holderBNB;
        Trader_BNBvalue = traderBNB;
    return (Holder_BNBvalue, Trader_BNBvalue);
    }

    function associate_timer() public view returns (uint256 Holder_timer, uint256 Trader_timer){
        Holder_timer = holderTimer;
        Trader_timer = traderTimer;
    return (Holder_timer, Trader_timer);
    }

    function set_TitleValues(uint256 _holderBNB, uint256 _traderBNB) public{
        holderBNB = _holderBNB *10**18;
        traderBNB = _traderBNB *10**18;
    emit titleValues(msg.sender, _holderBNB, _traderBNB);
    }
 
    function set_AssociatesTime(uint256 _holderTimer, uint256 _traderTimer) public returns(bool){
        holderTimer = _holderTimer;
        traderTimer = _traderTimer;
    emit associateTime(msg.sender, _holderTimer, _traderTimer);
    return true;
    }

    function checksAssociate() public laserTimer(msg.sender) returns(bool Holder, bool Trader){
    Holder = HolderAssociate[msg.sender];
    Trader = TraderAssociate[msg.sender];
    return (Holder, Trader);
    }

    function Holder_associate() public payable {
    require(!TraderAssociate[msg.sender] || !HolderAssociate[msg.sender], "O endereço nao pode associar mais de uma vez em cada modalidade");
    require(msg.sender != address(0), "O endereço nao pode ser zero");
    require(msg.value == holderBNB, "Voce nao possue saldo suficiente");
        expiryHolder[msg.sender] = block.timestamp + holderTimer;
        HolderAssociate[msg.sender] = true;
        isAssociateHolder.push(msg.sender);
    emit holderAssociate(msg.sender, traderTimer);
    }

    function Trader_associate() public payable {
    require(!TraderAssociate[msg.sender] || !HolderAssociate[msg.sender], "O endereço nao pode associar mais de uma vez em cada modalidade");
    require(msg.sender != address(0), "O endereço nao pode ser zero");
    require(msg.value == traderBNB, "Voce nao possue saldo suficiente");
        expiryTrader[msg.sender] = block.timestamp + traderTimer;
        TraderAssociate[msg.sender] = true;
        isAssociateTrader.push(msg.sender);
    emit traderAssociate(msg.sender, traderTimer);
    }

}