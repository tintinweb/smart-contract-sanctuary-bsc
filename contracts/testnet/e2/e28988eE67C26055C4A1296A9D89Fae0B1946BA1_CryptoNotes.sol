/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract CryptoNotes{

    /**
     * Owner
     */
    address public owner;


    /**
     * Developer wallet (for donations)
     */
    address public devWallet;

    
    /**
     * User's structure
     */
    struct User{
        uint256 idUser;
        string nickName;
        uint totalNotes;
        bool isUser;
    }


    /**
     * User index
     */
    address[] internal kUser;


    /**
     * Mapping wallets to users
     */
    mapping(address => User) internal users;


    /**
     * Notes's structure
     */
    struct Note{
        uint256 idUser;     // User id (created_by)
        string noteTitle;   // Note title
        string noteBody;    // Note body
        uint256 noteId;     // Note index
        uint256 created_at; // timestamp created
        bool isValid;       // Validate note
    }


    /**
     * Preview Notes
     */
    struct PreviewNote{
        string created_by;     // Nickname
        string noteTitle;   // title
        uint256 created_at; // timestamp created
        uint256 noteId; // ID de nota
    }


    /**
     * Note index
     */
    uint256[] internal kNote;


    /**
     * Mapping note to an ID
     */
    mapping(uint256 => Note) notes;
    
    /**
     * Allow or disallow new notes
     */
    bool internal allowNewNotes;


    /**
     * Event NoteCreated
     * Triggered when a note is created
     */
    event NoteCreated(uint256 idNote, string title);

    /**
     * Event NickNameChanged
     * Triggered when a user changes their nickname
     */
    event NicknameChanged(string oldNickname, string newNickname);
    
    
    /**
     * Event NewNotesEnabled
     * Triggered when new notes are allowed or disallowed
     */
    event NewNotesEnabled(bool _npe);


    constructor() payable {
        owner = msg.sender;
        devWallet = 0xc69Be15252dBaC509009Af7c944b8E24C6d04887; // BSC testnet & mainnet 
        //devWallet = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // Javascript or ganache
        allowNewNotes = true;
    }


    function createNote(string calldata _noteTitle, string calldata _noteBody) external returns(uint256 noteId){
        require( allowNewNotes, "Cryptonotes: New notes are not allowed at this time." );
        User memory u;
        // Step 1: Check if sender already is a registred user, if not, create user
        if(! _isUserRegistered(msg.sender)){
            _createUser(msg.sender);
        }
        // Step 2: Get user ID
        u = users[msg.sender];
        // Step 3: Save note
        uint256 pp =_createNote(u.idUser, _noteTitle, _noteBody);
        users[msg.sender].totalNotes++;
        emit NoteCreated(pp, _noteTitle);
        
        return pp;

    }


    function createAccount() external{
        _createUser(msg.sender);
    }


    function isUserRegistered(address account) external view returns(bool RegisteredUser){
        return _isUserRegistered(account);
    }


    function getUserInfo(address account) external view returns(User memory user){
        require(_isUserRegistered(account), "Cryptonotes: User not registered");
        return users[account];
    }
    
    
    function countUserNotes(address _user) external view returns(uint256 totalNotes){
        require (_isUserRegistered(_user), "User not registered");
        return users[_user].totalNotes;
    }
    
    
    function countNotes() external view returns(uint256 totalNotes){
        return kNote.length;
    }
    
    
    function countUsers() external view returns(uint256 totalUsers){
        return kUser.length;
    }
    
    
    function changeNickName(string calldata _nickname) external {
        require (_isUserRegistered(msg.sender), "User not registered");
        string calldata old = _nickname;
        users[msg.sender].nickName = _nickname;
        emit NicknameChanged(old, _nickname);
    }
    
    
    function getNote(uint256 i) external view returns(uint256 noteId, address author, string memory title, string memory noteBody, string memory nickName, uint256 createdAt){
        require( _isValidNote(i), "Cryptonotes: Note not found!" );
        
        return (
            notes[i].noteId
            ,kUser[notes[i].idUser]
            ,notes[i].noteTitle
            ,notes[i].noteBody
            ,users[kUser[notes[i].idUser]].nickName
            ,notes[i].created_at
        );
    }


    /**
     * Receive donations
     */
    receive() external payable {
        // receive BNB (donations)
  	}
  	
  	
  	/**
     * Get Contract's balance (BNB)
     * @return uint256
     */
    function getBalance() external view returns(uint256){
  	    return address(this).balance;
  	}
  	
  	
  	function setDevWallet(address _newDevWallet) external {
  	    require(owner == msg.sender, "Cryptonotes: No owner");
  	    require(devWallet != _newDevWallet, "Cryptonotes: Dev weallet already is that address");
  	    _setDevWallet(_newDevWallet);
  	}
  	
  	
    function devWithdraw() external payable {
        require(owner == msg.sender, "Cryptonotes: No owner");
        require(address(this).balance > 0, "Cryptonotes: Cannot send 0 BNB");

        bool sent = payable(devWallet).send(address(this).balance);
        require(sent, "Failed to send Balance");
    }
    
    
    function AllowOrDisallowNewNotes() external{
         require(owner == msg.sender, "Cryptonotes: No owner");
         allowNewNotes = !allowNewNotes;
         emit NewNotesEnabled(allowNewNotes);
    }
    
    
    function newNotesEnabled() external view returns(bool){
        return allowNewNotes;
    }


    function about() external pure returns(string memory){
        return "Cryptonotes by Underdog1987. Made with love in MX";
    }


    function getLatestNotes() external view returns(PreviewNote[] memory latestNoteZ, uint256 _first, uint256 _last){
        return _getLatestNotes();
    }


  	
  	/////////////////////////////////////////////////////////////////

    /**
     * Check if address is already registered
     *
     * @param uZer address Address to check
     * @return userAlreadyRegistered bool
     */
    function _isUserRegistered(address uZer) internal view returns(bool userAlreadyRegistered){
        if(kUser.length == 0) return false;
        return users[uZer].isUser && kUser[ users[uZer].idUser ] == uZer;
    }


    /**
     * Register wallet as User
     *
     * @param _newUser address Wallet address
     */
    function _createUser(address _newUser) internal{
        require(!_isUserRegistered(_newUser), "Cryptonotes: User already registered");
        kUser.push(_newUser);
        users[_newUser].idUser =  kUser.length -1;
        users[_newUser].nickName = "Anonymous User";
        users[_newUser].totalNotes = 0;
        users[_newUser].isUser = true;
    }


    /**
     * Create New Note
     *
     * @param userId uint256 user ID
     * @param pt string  Note's title
     * @param pb string Note's body
     * @return pid uint256 Note's ID
     */
    function _createNote(uint256 userId, string calldata pt, string calldata pb) internal returns(uint256 pid) {
        
        kNote.push(userId);
        uint256 l = kNote.length -1;
        notes[l].idUser = userId;
        notes[l].noteTitle = pt;
        
        notes[l].noteBody = pb;
        notes[l].created_at = block.timestamp;
        notes[l].noteId = l;
        notes[l].isValid = true;

        return l;
    }
    
    
    /**
     * Check if note exists
     *
     * @param index uint256 Note ID
     * @return valid bool
     */
    function _isValidNote(uint256 index) internal view returns( bool valid){
        if(kNote.length == 0) return false;
        return notes[index].isValid;
    }



    /**
     * Get latest 5 notes
     *
     * @return latestNoteZ Note[] Last 5 notes
     * @return _first uint256 first Note ID
     * @return _last uint256 last note ID
     */
    function _getLatestNotes() internal view returns(PreviewNote[] memory latestNoteZ, uint256 _first, uint256 _last){
        require(kNote.length > 0, "Cryptonotes: There are no notes. Click 'Create Note' and create first one!" );
        PreviewNote[] memory ret = new PreviewNote[](5);
        uint256 ultima = kNote.length -1;
        uint256 primera = kNote.length <= 4 ? 0 : ultima -4;
        uint8 y = 0;
        uint256 x;
        for(x=primera;x<=ultima;x++){
            if(_isValidNote(x)){
                // get note
                ret[y].created_by = users[kUser[notes[x].idUser]].nickName;
                ret[y].noteTitle = notes[x].noteTitle;
                ret[y].created_at = notes[x].created_at;
                ret[y].noteId = notes[x].noteId;
                y++;
            }
        }
        return (ret, primera, ultima);
    }
    
    
    /**
     * Set developer wallet
     *
     * @param _ndw address New dev wallet
     */
    function _setDevWallet(address _ndw) internal{
        devWallet = _ndw;
    }
    
}