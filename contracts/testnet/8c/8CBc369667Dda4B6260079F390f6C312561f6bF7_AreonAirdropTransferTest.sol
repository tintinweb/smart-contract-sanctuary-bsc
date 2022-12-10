// SPDX-License-Identifier: MIT

/*

▄▀█ █▀█ █▀▀ █▀█ █▄░█   █▄░█ █▀▀ ▀█▀ █░█░█ █▀█ █▀█ █▄▀
█▀█ █▀▄ ██▄ █▄█ █░▀█   █░▀█ ██▄ ░█░ ▀▄▀▄▀ █▄█ █▀▄ █░█

THIS SMART CONTRACT IS PREPARED TO TRANSFER AIRDROP AREON TOKENS. IT CAN ONLY BE USED FOR THIS PURPOSE.     
                                                                                                                                             
*/

pragma solidity ^0.8.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

}

abstract contract Ownable is Context {

    address private _owner = _msgSender() ;

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

}

interface BEP20 {    
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract AreonAirdropTransferTest is Context, Ownable, BEP20 {

    event WithdrawToken(address indexed to, uint value);
    event AddRecipient(address[] indexed recipient);
    event DeleteRecipient(address indexed recipient);

    uint public count = 0;
    address public tokenContractAddress = 0x9319273E13735127CfAe844Ebeb4322Bd311a27c;
    address public thisContractAddress = address(this);

    struct RecipientSchema {
        uint amount;
        bool exists;
    }

    mapping(address => RecipientSchema) private recipientList;
    mapping(address => uint) private balances;

    modifier recipientCheck(address _address) {
        require(recipientList[_address].exists == true, "This recipient not found."); 
        _;
    }
    
    constructor() {
        createAirdropList();
    }

    function createAirdropList() private onlyOwner{
        recipientList[0x08C94Db876F1B6114a50eB685Bd7607dF77573d9] = RecipientSchema(255, true);
        count = 1;
    }

    function addRecipient(address[] calldata addresses, uint[] calldata amounts) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
          require(addresses[i] != address(0), "Can not add the null address.");
            if(recipientList[addresses[i]].exists == false){
                recipientList[addresses[i]] = RecipientSchema(amounts[i], true);
                count++;
            }
        }
        emit AddRecipient(addresses);
    }


    function deleteRecipient(address _address) external onlyOwner recipientCheck(_address){
        delete recipientList[_address];
        count--;
        emit DeleteRecipient(_address);
    }
    
    function isRecipient(address _address) external view returns(bool){ 
        return recipientList[_address].exists;
    }

    function getRecipient(address _address) public onlyOwner recipientCheck(_address) view returns(RecipientSchema memory){
        return recipientList[_address];
    }

    function getTotalTokenBalance() external onlyOwner view returns(uint) {
        BEP20 token = BEP20(tokenContractAddress);
        return token.balanceOf(thisContractAddress);
    }

    function withdrawToken(uint _amount) external recipientCheck(_msgSender()){
        require(_amount > 0, "Amount must be greater than zero.");
        require(recipientList[_msgSender()].amount >= _amount, "Amount you withdraw can not be large");
        uint sendAmount = _amount*10**18;                      
        BEP20(tokenContractAddress).transfer(_msgSender(), sendAmount);
        recipientList[_msgSender()].amount = recipientList[_msgSender()].amount - _amount;
        emit WithdrawToken(_msgSender(), _amount);
    }

    function withdrawAllBnb() public onlyOwner {
        address payable to = payable(_msgSender());
        to.transfer(address(this).balance);
    }

    function transfer(address _recipient, uint _amount) external override returns (bool) {}

    function balanceOf(address _account) public view virtual override returns (uint) {
        return balances[_account];
    }

}