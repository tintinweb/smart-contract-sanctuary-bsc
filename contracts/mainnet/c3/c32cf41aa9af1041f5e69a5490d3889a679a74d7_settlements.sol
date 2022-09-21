/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

pragma solidity ^0.5.0;

contract settlements{
    mapping(address=>mapping(address=>uint256)) public payout;
    mapping(address=>mapping(address=>mapping(uint256=>bool))) public senderAgrees;
    mapping(address=>mapping(address=>uint256)) public amount;
    mapping(address=>mapping(address=>bool)) public dispute;
    mapping(address=>mapping(address=>uint256)) public disputeamount;
    mapping(address=>mapping(address=>bool)) public disputeHandled;
    mapping(address=>bool) public admin;
    uint256 public tax=1000000;
    uint256 public adminfee=0;
    uint256 public ownerfee=0;
    uint256 public flatfee=0;
    address payable public owner;
    //People send money to the contract and indicate recipient
    //The money is locked in the contract
    //when sender agrees with recipient to pay out cash the money is payed out
    //Both sender and recipient have the option to dispute

    event SenderDispute(
        address indexed _sender,
        uint _amount
    );

    event RecipientDispute(
        address indexed _recipient,
        uint _amount
    );

    constructor() public {
        owner=msg.sender;
        admin[msg.sender]=true;
    }

    function send(address _recipient) payable public returns (bool success){
        require(msg.value>0);
        require((msg.value*1000000)/tax>=flatfee);
        payout[msg.sender][_recipient]=(msg.value*1000000)/tax-flatfee;
        owner.transfer(msg.value-payout[msg.sender][_recipient]);
        return true;
    }

    function senderAgree(address _recipient, uint _amount) public returns (bool success){
        require(_amount<=payout[msg.sender][_recipient]);
        senderAgrees[msg.sender][_recipient][_amount]=true;
        amount[msg.sender][_recipient]=_amount;
        return true;
    }

    function withdrawFunds(address _sender, address payable _recipient) public returns (bool success){
        require(senderAgrees[_sender][_recipient][amount[_sender][_recipient]]==true);
        _recipient.transfer(amount[_sender][_recipient]);
        senderAgrees[_sender][_recipient][amount[_sender][_recipient]]=false;
        payout[_sender][_recipient]-=amount[_sender][_recipient];
        amount[_sender][_recipient]=0;
        return true;
    }

    function openDispute(address _sender, address _recipient, uint _amount) public returns (bool success){
        require(payout[_sender][_recipient]<=_amount);
        if(msg.sender==_sender){
            dispute[_sender][_recipient]=true;
            disputeamount[_sender][_recipient]=_amount;
            emit SenderDispute(msg.sender,_amount);
            disputeHandled[_sender][_recipient]=false;
            return true;
        }
        else if(msg.sender==_recipient){
            dispute[_sender][_recipient]=true;
            disputeamount[_sender][_recipient]=_amount;
            emit RecipientDispute(_recipient,_amount);
            disputeHandled[_sender][_recipient]=false;
            return true;
        }
        else{
            revert();
        }
    }

    function clearPayment(address payable _sender, address payable _recipient, address _winner, address payable _admin) public returns (bool success){
        require(admin[msg.sender]==true);
        require(_admin==msg.sender);
        require(payout[_sender][_recipient]>=disputeamount[_sender][_recipient]);
        require(dispute[_sender][_recipient]==true);
        require(disputeHandled[_sender][_recipient]==false);
        if(disputeamount[_sender][_recipient]<=adminfee+ownerfee){
            if(disputeamount[_sender][_recipient]<=adminfee){
                _admin.transfer(disputeamount[_sender][_recipient]);
                payout[_sender][_recipient]-=disputeamount[_sender][_recipient];
                disputeamount[_sender][_recipient]=0;
                amount[_sender][_recipient]=0;
                disputeHandled[_sender][_recipient]=true;
                return true;
            }
            else{
                _admin.transfer(adminfee);
                owner.transfer(disputeamount[_sender][_recipient]-adminfee);
                payout[_sender][_recipient]-=disputeamount[_sender][_recipient];
                disputeamount[_sender][_recipient]=0;
                amount[_sender][_recipient]=0;
                disputeHandled[_sender][_recipient]=true;
            }
        }
        else{
            if(_sender==_winner){
                _sender.transfer(disputeamount[_sender][_recipient]-adminfee-ownerfee);
                owner.transfer(ownerfee);
                _admin.transfer(adminfee);
                payout[_sender][_recipient]-=disputeamount[_sender][_recipient];
                disputeamount[_sender][_recipient]=0;
                amount[_sender][_recipient]=0;
                disputeHandled[_sender][_recipient]=true;
                return true;
            }
            else if(_recipient==_winner){
                _recipient.transfer(disputeamount[_sender][_recipient]-adminfee-ownerfee);
                owner.transfer(ownerfee);
                _admin.transfer(adminfee);
                payout[_sender][_recipient]-=disputeamount[_sender][_recipient];
                disputeamount[_sender][_recipient]=0;
                amount[_sender][_recipient]=0;
                disputeHandled[_sender][_recipient]=true;
                return true;
            }
            else{
                revert();
            }
        }
    }

    function closeDispute(address _sender, address _recipient) public returns (bool success){
        require(disputeHandled[_sender][_recipient]==true);
        dispute[_sender][_recipient]=false;
        return true;
    }

    function setFeeSchedule(uint _tax, uint _flatfee, uint _adminfee, uint _ownerfee) public returns (bool success){
        require(msg.sender==owner);
        require(_tax>=1000000);
        tax=_tax;
        flatfee=_flatfee;
        adminfee=_adminfee;
        ownerfee=_ownerfee;
        return true;
    }
    
    function addAdmin(address _admin) public returns (bool success){
        require(msg.sender==owner);
        admin[_admin]=true;
        return true;
    }

    function removeAdmin(address _admin) public returns (bool success){
        require(msg.sender==owner);
        admin[_admin]=false;
        return true;
    }
}