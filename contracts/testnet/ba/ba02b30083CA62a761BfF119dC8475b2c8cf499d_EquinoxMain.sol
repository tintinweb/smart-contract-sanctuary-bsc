/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    function _transfer(address _from, address _to, uint256 _value) external ;
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


contract EquinoxMain {

    address public productOwner = 0x9c333A1A1dcC8C0d517EB5BEC014c0EDd5d76c2f;

    address public owner;
    
    address[] public signers;
    
    address public equinox;

    IERC20 public gToken;
    
    uint256 public taxAmountInWei = 600000000000000;

    mapping(address => bool) public canSign;

    // Proposal I  : ICO Proposal - Variables
     struct Proposal{
        address to;
        uint amount;
        uint256 tokenAmount;
        address tokenAddress;
        bool finalized;
        bool disapproved;
    }
    
    mapping(uint => mapping(address => bool)) proposalDisapproved;
    mapping(uint => mapping(address => bool)) proposalSigned;

    Proposal[] public proposals;

    uint public signersRequired;

    // Proposal II : Remove Member Proposal - Variables
    struct removeMember{
        address member;
        bool finalized;  
        bool disapproved;
    }
    
    mapping(uint => mapping(address => bool)) public removeMemberProposalDisapproved;
    mapping(uint => mapping(address => bool)) public removeMemberProposalSigned;
     
    removeMember[] public members;
    
    uint public removeMemberSignersRequired;

    // Proposal III : Add Member Proposal - Variables
    struct addMember{
        address member;
        bool finalized;  
        bool disapproved;
    }
    
    mapping(uint => mapping(address => bool)) addMemberProposalDisapproved;
    mapping(uint => mapping(address => bool)) public addMemberProposalSigned;
     
    addMember[] public addedmembers;
    
    uint public addMemberSignersRequired;

    // Proposal IV  : Transfer Proposal - Variables
     struct TransferProposal{
        address from;
        address to;
        uint256 tokenAmount;
        address tokenAddress;
        bool finalized;
        bool disapproved;
    }
    
    mapping(uint => mapping(address => bool)) transferProposalDisapproved;
    mapping(uint => mapping(address => bool)) transferProposalSigned;

    TransferProposal[] public transferProposals;

    uint public transferSignersRequired;

    // Proposal V  : Basic Proposal - Variables
     struct BasicProposal{
        bool finalized;
        bool disapproved;
    }
    
    mapping(uint => mapping(address => bool)) basicProposalDisapproved;
    mapping(uint => mapping(address => bool)) basicProposalSigned;

    BasicProposal[] public basicProposals;

    uint public basicSignersRequired;
    
    constructor(address[] memory initialSigners,address _equinox) payable {
        
        signersRequired = initialSigners.length;
        
        removeMemberSignersRequired = initialSigners.length * 51/100;

        addMemberSignersRequired = initialSigners.length;

        transferSignersRequired = initialSigners.length;

        basicSignersRequired = initialSigners.length * 51/100;
      
        signers = initialSigners;
        
        equinox = _equinox;

        owner = msg.sender;
        
        for(uint i=0; i < initialSigners.length; i++){
            
            canSign[initialSigners[i]] = true;
        }

    }
    
    modifier isSigner(address user) {
        
        require(canSign[user] == true);
        _;
    }

    function balance() public view returns(uint){
        
        return address(this).balance;
    }

    function listSigners() public view returns(address[] memory){
        return signers;
    }

    function transferGtoken(uint256 amount, address account) public isSigner(msg.sender){
        gToken.transfer(account, amount);
    }
    
    // Proposal I  : ICO Proposal - Functions

    // 1. Function : Creates a Proposal
    function submitProposal(uint amount, uint256 tokenAmount, address tokenAddress, address to) public payable isSigner(msg.sender){
        require(msg.value == taxAmountInWei, "INSUFFICIENT_TAX_AMOUNT_BNB_SENT");
        proposals.push(Proposal({
            to:to,
            amount: amount,
            tokenAmount: tokenAmount,
            tokenAddress: tokenAddress,
            finalized: false,
            disapproved: false
        }));
        payable(productOwner).transfer(taxAmountInWei);
    }

    // 2. Modifier : Checks if the proposal exists
    modifier proposalExists(uint index){
        
        require(index >= 0);
        require(index < proposals.length);
        _;
    }

    // 3. Function : Signer can sign function 
    function sign(uint proposalIndex) public isSigner(msg.sender) proposalExists(proposalIndex) payable{
        
       // proposals[proposalIndex].signed[msg.sender] = true;
        
        proposalSigned[proposalIndex][msg.sender] = true;

    }

    // 4. Function : Check if the requirements are met for proposal
    function signerRequirementMet(uint index) public view proposalExists(index) returns(bool) {
       
       uint signedCount = 0;
       
       for(uint i=0; i < signers.length; i++){
           
          if(proposalSigned[index][signers[i]]== true){
              
              signedCount++;
          }
       } 
        
        return signedCount >= signersRequired;
    }
    
    // 5. Modifier : Check if the requirements are met for proposal
    modifier isFullySigned(uint index) {
        
        require(signerRequirementMet(index));
        _;
    }

    // 6. Function : Finalize Proposal
    function finalizeProposal(uint index, address icoTokenAddress) isFullySigned(index) isSigner(msg.sender) public {
        
        require( proposals[index].disapproved == false);
        require(IERC20(equinox).balanceOf(address(this)) >= proposals[index].amount);
        require(proposals[index].finalized == false);
        
        proposals[index].finalized = true;
        IERC20(proposals[index].tokenAddress).transfer(icoTokenAddress, proposals[index].tokenAmount);
        IERC20(equinox).transfer(proposals[index].to,proposals[index].amount);
    }

    // 7. Function : List Proposals
    function listProposals() public view returns(Proposal[] memory){
        return proposals;
    }

    // 8. Function : Checks if the user has signed the Proposal
    function isSigned(uint256 index, address signer) public view returns(bool) {
        return proposalSigned[index][signer];
    }

    // 9. Disapprove
    function disapproveProposal(uint256 index) public payable{
        proposalDisapproved[index][msg.sender] = true;
        proposals[index].disapproved = true;
    }

    // 10. Function : Checks if the user has disapproved the Proposal
    function isProposalDisapproved(uint256 index, address signer) public view returns(bool) {
        return proposalDisapproved[index][signer];
    }

    function isFinalICOProposal(uint256 index) public view returns(bool) {
        return !proposals[index].disapproved;
    }

    // Proposal II : Remove member Proposal - Functions
    
    // 1. Function :  Creates a proposal
    function removeMemberProposal(address _address) public isSigner(msg.sender) isSigner(_address) payable{
        require(msg.value == taxAmountInWei, "INSUFFICIENT_TAX_AMOUNT_BNB_SENT");
        members.push(removeMember({
            member:_address,
            finalized: false,
            disapproved: false
        }));
        payable(productOwner).transfer(taxAmountInWei);
    }

    // 2. Modifier : Checks if the proposal exists
    modifier removeMemberProposalExist(uint index){
        
        require(index >= 0);
        require(index < members.length);
        _;
    }

    // 3. Function : Signer can sign function
    function signRemoveMemberProposal(uint proposalIndex) public isSigner(msg.sender) removeMemberProposalExist(proposalIndex) payable{
        
        removeMemberProposalSigned[proposalIndex][msg.sender] = true;

    }

    
    // 4. Function : Check if the requirements are met for proposal
    function removeProposalRequirementMet(uint index) public view removeMemberProposalExist(index) returns(bool){
        
        uint signedCount = 0;
        
        for(uint i=0; i < signers.length; i++){
            
            if(removeMemberProposalSigned[index][signers[i]] == true){
                
                signedCount++;
            }
        }
        
        return signedCount >= removeMemberSignersRequired;
    }

    // 5. Modifier : Check if the requirements are met for proposal
      modifier isRemovable(uint index) {
        
        require(removeProposalRequirementMet(index));
        _;
    }

    function getSignerIndex(uint256 index) view private returns(uint256)  {
        uint256 ind;
        for(uint i=0; i < signers.length; i++){    
            if (signers[i] == members[index].member) {
                ind = i;
                break;
            }
        }
        
        return ind;
    }

    // 6. Function : Finalize Proposal
    function removeWalletMember(uint index) isRemovable(index) isSigner(msg.sender) public{
        
        require(members[index].finalized == false);
        members[index].finalized = true;
        canSign[members[index].member] = false;
        uint256 signerLength = signers.length;
        uint256 signerIndex = getSignerIndex(index);
        delete signers[signerIndex];
        signerLength = signerLength - 1;
        signersRequired = signerLength;
        removeMemberSignersRequired = signerLength * 51/100;
        addMemberSignersRequired = signerLength;
        transferSignersRequired = signerLength;
        basicSignersRequired = signerLength * 51/100;
    }

    // 7. Function : List Proposals
    function listRemoveMembers() public view returns(removeMember[] memory) {
        return members;
    }

    // 8. Function : Checks if the user has signed the Proposal
    function hasRemoveMemberProposolSigned(uint index, address account) public view returns(bool){
        return removeMemberProposalSigned[index][account];
    }

    // 9. Disapprove
    function disapproveRemoveMemberProposal(uint256 index) public payable{
        removeMemberProposalDisapproved[index][msg.sender] = true;
    }

    // 10. Function : Checks if the user has disapproved the Proposal
    function isRemoveMemberProposalDisapproved(uint256 index, address signer) public view returns(bool) {
        return removeMemberProposalDisapproved[index][signer];
    }

    function isFinalRemoveMemberProposal(uint256 index) public view returns(bool) {

        uint disapproveCount = 0;
        
        for(uint i=0; i < signers.length; i++){
            if(removeMemberProposalDisapproved[index][signers[i]] == true){
                disapproveCount++;
            }
        }
        return disapproveCount > removeMemberSignersRequired;
    }

    // Proposal III : Add member Proposal - Functions
    
    // 1. Function :  Creates a proposal
    function addMemberProposal(address _address) public payable isSigner(msg.sender){
        require(msg.value == taxAmountInWei, "INSUFFICIENT_TAX_AMOUNT_BNB_SENT");
        addedmembers.push(addMember({
            member:_address,
            finalized: false,
            disapproved: false
        }));
        payable(productOwner).transfer(taxAmountInWei);
    }

    // 2. Modifier : Checks if the proposal exists
    modifier addMemberProposalExist(uint index){
        
        require(index >= 0);
        require(index < addedmembers.length);
        _;
    }

    // 3. Function : Signer can sign function
    function signAddMemberProposal(uint proposalIndex) public isSigner(msg.sender) addMemberProposalExist(proposalIndex){

        addMemberProposalSigned[proposalIndex][msg.sender] = true;

    }

    // 4. Function : Check if the requirements are met for proposal
    function addMemberProposalRequirementMet(uint index) public view addMemberProposalExist(index) returns(bool){
        
        uint signedCount = 0;
        
        for(uint i=0; i < signers.length; i++){
            
            if(addMemberProposalSigned[index][signers[i]] == true){
                
                signedCount++;
            }
        }
        
        return signedCount >= addMemberSignersRequired;
    }

    // 5. Modifier : Check if the requirements are met for proposal
    modifier isAddable(uint index) {
        
        require(addMemberProposalRequirementMet(index));
        _;
    }
    
    // 6. Function : Finalize Proposal
    function finalizeAddMemberProposal(uint index) isAddable(index) isSigner(msg.sender) public{
        
        require(addedmembers[index].disapproved == false);
        require(addedmembers[index].finalized == false);
        addedmembers[index].finalized = true;
        uint256 signerLength = signers.length;
        signers.push(addedmembers[index].member);
        signerLength = signerLength + 1;
        signersRequired = signers.length;
        removeMemberSignersRequired = signers.length * 51/100;
        addMemberSignersRequired = signers.length;
        transferSignersRequired = signers.length;
        basicSignersRequired = signers.length * 51/100;
        canSign[addedmembers[index].member] = true;

    }

    // 7. Function : List Proposals
    function listAddedMembers() public view returns(addMember[] memory) {
        return addedmembers;
    }

    // 8. Function : Checks if the user has signed the Proposal
    function hasAddMemberProposolSigned(uint index, address account) public view returns(bool){
        return addMemberProposalSigned[index][account];
    }

    // 9. Disapprove
    function disapproveAddMemberProposal(uint256 index) public {
        addMemberProposalDisapproved[index][msg.sender] = true;
        addedmembers[index].disapproved = true;

    }

    // 10. Function : Checks if the user has disapproved the Proposal
    function isAddMemberProposalDisapproved(uint256 index, address signer) public view returns(bool) {
        return addMemberProposalDisapproved[index][signer];
    }
    
    function isFinalAddmemberProposal(uint256 index) public view returns(bool) {
        return !addedmembers[index].disapproved;
    }

    // Proposal IV  : Transfer Proposal - Functions

    // 1. Function : Creates a Proposal
    function submitTransferProposal( uint256 tokenAmount, address tokenAddress, address to) public payable isSigner(msg.sender){
        require(msg.value == taxAmountInWei, "INSUFFICIENT_TAX_AMOUNT_BNB_SENT");
        transferProposals.push(TransferProposal({
            from: msg.sender,
            to:to,
            tokenAmount: tokenAmount,
            tokenAddress: tokenAddress,
            finalized: false,
            disapproved: false
        }));
        payable(productOwner).transfer(taxAmountInWei);
    }

    // 2. Modifier : Checks if the proposal exists
    modifier transferProposalExists(uint index){
        
        require(index >= 0);
        require(index < transferProposals.length);
        _;
    }

    // 3. Function : Signer can sign function 
    function signTransferProposal(uint proposalIndex) public isSigner(msg.sender) transferProposalExists(proposalIndex){
        
        transferProposalSigned[proposalIndex][msg.sender] = true;

    }

    // 4. Function : Check if the requirements are met for proposal
    function transferProposalSignerRequirementMet(uint index) public view transferProposalExists(index) returns(bool) {
       
       uint signedCount = 0;
       
       for(uint i=0; i < signers.length; i++){
           
          if(transferProposalSigned[index][signers[i]]== true){
              
              signedCount++;
          }
       } 
        
        return signedCount >= transferSignersRequired;
    }
    
    // 5. Modifier : Check if the requirements are met for proposal
    modifier isTransferProposalFullySigned(uint index) {
        
        require(transferProposalSignerRequirementMet(index));
        _;
    }

    // // 6. Function : Finalize Proposal
    function finalizeTransferProposal(uint index) isTransferProposalFullySigned(index) isSigner(msg.sender) public {
        
        require(transferProposals[index].disapproved == false);
        require(IERC20(transferProposals[index].tokenAddress).balanceOf(address(this)) >= transferProposals[index].tokenAmount);
        require(transferProposals[index].finalized == false);
        
        transferProposals[index].finalized = true;
        IERC20(transferProposals[index].tokenAddress).transfer(transferProposals[index].to, transferProposals[index].tokenAmount);
    }

    // 7. Function : List Proposals
    function listTransferProposals() public view returns(TransferProposal[] memory){
        return transferProposals;
    }

    // 8. Function : Checks if the user has signed the Proposal
    function isTransferProposalSigned(uint256 index, address signer) public view returns(bool) {
        return transferProposalSigned[index][signer];
    }

    // 9. Disapprove
    function disapproveTransferProposal(uint256 index) public {
        transferProposalDisapproved[index][msg.sender] = true;
        transferProposals[index].disapproved = true;

    }

    // 10. Function : Checks if the user has disapproved the Proposal
    function isTransferProposalDisapproved(uint256 index, address signer) public view returns(bool) {
        return transferProposalDisapproved[index][signer];
    }

    function isFinalTransferProposal(uint256 index) public view returns(bool) {
        return !transferProposals[index].disapproved;
    }

     // Proposal V  : Basic Proposal - Functions

    // 1. Function : Creates a Proposal
    function submitBasicProposal() public payable isSigner(msg.sender){
        require(msg.value == taxAmountInWei, "INSUFFICIENT_TAX_AMOUNT_BNB_SENT");
        basicProposals.push(BasicProposal({
            finalized: false,
            disapproved: false
        }));
        payable(productOwner).transfer(taxAmountInWei);
        
    }

    // 2. Modifier : Checks if the proposal exists
    modifier basicProposalExists(uint index){
        
        require(index >= 0);
        require(index < basicProposals.length);
        _;
    }

    // 3. Function : Signer can sign function 
    function signBasicProposal(uint proposalIndex) public isSigner(msg.sender) basicProposalExists(proposalIndex){
        
        basicProposalSigned[proposalIndex][msg.sender] = true;
    }

    // 4. Function : Check if the requirements are met for proposal
    function basicProposalSignerRequirementMet(uint index) public view basicProposalExists(index) returns(bool) {
       
       uint signedCount = 0;
       
       for(uint i=0; i < signers.length; i++){
           
          if(basicProposalSigned[index][signers[i]]== true){
              
             signedCount++;
          }
       } 
        
        return signedCount >= basicSignersRequired;
    }
    
    // 5. Modifier : Check if the requirements are met for proposal
    modifier isBasicProposalFullySigned(uint index) {
        
        require(basicProposalSignerRequirementMet(index));
        _;
    }

    // // 6. Function : Finalize Proposal
    function finalizeBasicProposal(uint index) isBasicProposalFullySigned(index) isSigner(msg.sender) public {
        
        require(basicProposals[index].finalized == false);
        basicProposals[index].finalized = true;

        //require(members[index].finalized == false);
        //members[index].finalized = true;
        //canSign[members[index].member] = false;
        uint256 signerLength = signers.length;
        //uint256 signerIndex = getSignerIndex(index);
        //delete signers[signerIndex];
        signerLength = signerLength - 1;
        signersRequired = signerLength;
        removeMemberSignersRequired = signerLength * 51/100;
        addMemberSignersRequired = signerLength;
        transferSignersRequired = signerLength;
        basicSignersRequired = signerLength * 51/100;


       
    }

    // 7. Function : List Proposals
    function listBasicProposals() public view returns(BasicProposal[] memory){
        return basicProposals;
    }

    // 8. Function : Checks if the user has signed the Proposal
    function isBasicProposalSigned(uint256 index, address signer) public view returns(bool) {
        return basicProposalSigned[index][signer];
    }

    // 9. Disapprove
    function disapproveBasicProposal(uint256 index) public {
        basicProposalDisapproved[index][msg.sender] = true;
    }

    // 10. Function : Checks if the user has disapproved the Proposal
    function isBasicProposalDisapproved(uint256 index, address signer) public view returns(bool) {
        return basicProposalDisapproved[index][signer];
    }

    function isFinalBasicProposal(uint256 index) public view returns(bool) {

        uint disapproveCount = 0;
        
        for(uint i=0; i < signers.length; i++){
            if(basicProposalDisapproved[index][signers[i]] == true){
                disapproveCount++;
            }
        }
        return disapproveCount > basicSignersRequired;
    }
    
    //fallback payable function to receive ethers in contract
    receive() external payable{}
}