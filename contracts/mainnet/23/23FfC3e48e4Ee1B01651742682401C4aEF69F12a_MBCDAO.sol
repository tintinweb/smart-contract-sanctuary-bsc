/**
 *Submitted for verification at BscScan.com on 2023-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

/**

 DOA Based Smart Contract For (Meta Bridge (MBC)) Community

 What is a DAO in blockchain?
 what is a DAO? A decentralized autonomous organization is exactly what the name says; 
 a group of people who come together without a central leader or company dictating any of the 
 decisions.They are built on a blockchain using smart contracts (digital one-of-one agreements)

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value); 
}

interface IBNBCONTRACT {
    function GETTotalStakedGE(address account) external view returns (uint256);
}

abstract contract MBCInitialize {

    IBNBCONTRACT public nativeContract;
    IBEP20 public nativeToken;
    address public contractOwner;

    string  questionNo;
    string  questionTopic;
    string  questionExplanation;

    uint  noofYes;
    uint  noofNo;
    uint256  yesHoldedMBC;
    uint256  noHoldedMBC;

    struct UserDAOParticipateStatus {
        string votingno;
        address wallet;
        string questionNo;
        string remark;
        bool votestatus;
        bool vote;
        uint256 votingWeight;
	}

    mapping (string => UserDAOParticipateStatus) public getUserDAOParticipateStatus;

    event AskQuestion(string _questionNo,string _questionTopic,string _questionExplanation);
	event Vote(address indexed _user,uint _vote);

    constructor() {
        contractOwner = 0x6D24d7856dceF3F389Ad3483564FEA59B5bE1F1A;
        nativeContract = IBNBCONTRACT(0xACAC2eB039A3F1A48f2596FAA1990D2d02E66144);
        nativeToken = IBEP20(0x1ae848CA067AdEA97b05a729b4cEcdAdefa84d07);
    }

}

contract MBCDAO is MBCInitialize {

    // Update Native Contract
    function update_NativeContract(address _nativeContract) public {
      require(contractOwner==msg.sender, 'Admin what?');
      nativeContract = IBNBCONTRACT(_nativeContract);
    }

    // Update Token Contract
    function update_TokenContract(address _nativeToken) public {
      require(contractOwner==msg.sender, 'Admin what?');
      nativeToken = IBEP20(_nativeToken);
    }

    // DAO Question :- ASK QUESTION
    function ask_DAO_Question(string memory _questionNo,string memory _questionTopic,string memory _questionExplanation) external {
      require(contractOwner==msg.sender, 'Admin what?');
      noofYes=0;
      noofNo=0;
      yesHoldedMBC=0;
      noHoldedMBC=0;
      questionNo=_questionNo;
      questionTopic=_questionTopic;
      questionExplanation=_questionExplanation;
      emit AskQuestion(_questionNo,_questionTopic,_questionExplanation);
    }

    // View DAO Question THat Is Asked By Contract Owner
    function view_DAO_Asking_Question()external view returns(string memory _questionNo,string memory _questionTopic,string memory _questionExplanation){
       return (questionNo,questionTopic,questionExplanation);
    }

    // View DAO Decisions
    function view_DAO_Decisions()external view returns(string memory _questionNo,string memory _questionTopic,string memory _questionExplanation,uint _noofYes,uint _noofNo,uint256 _yesHoldedGE,uint256 _noHoldedGE){
       return (questionNo,questionTopic,questionExplanation,noofYes,noofNo,yesHoldedMBC,noHoldedMBC);
    }

    // Give Vote Either true i.e Yes OR false i.e No
    function vote_In_DAO(uint _vote,string memory _votingno,string memory _remark,string memory _questionNo) public {
        require(getUserDAOParticipateStatus[_votingno].votestatus==false ,' Already Voted !');
        UserDAOParticipateStatus storage userDAOparticipatestatus = getUserDAOParticipateStatus[_votingno];
        userDAOparticipatestatus.votingno=_votingno;
        userDAOparticipatestatus.wallet=msg.sender;
        userDAOparticipatestatus.questionNo=_questionNo;
        userDAOparticipatestatus.remark=_remark;
        userDAOparticipatestatus.votestatus=true;
        
        userDAOparticipatestatus.votingWeight=(nativeToken.balanceOf(msg.sender)+nativeContract.GETTotalStakedGE(msg.sender));
        if(_vote==1){
            userDAOparticipatestatus.vote=true;
            noofYes +=1;
            yesHoldedMBC += (nativeToken.balanceOf(msg.sender)+nativeContract.GETTotalStakedGE(msg.sender));
        }
        else{
            userDAOparticipatestatus.vote=false;
            noofNo +=1;
            noHoldedMBC += (nativeToken.balanceOf(msg.sender)+nativeContract.GETTotalStakedGE(msg.sender));
        }
        emit Vote(msg.sender,_vote);
    }
}