// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;
    import "./base.sol";
/// @title A Decentralised Social Media Platform
/// @author Mohit Bhat
/// @notice You can use this contract to connect to decentralised social network, share your content to the world in a decentralised way!
/// @dev Most of the features are implemented keeping note of security concerns

    contract Reddit is Ownable{
    using SafeMath for uint256;
    // address payable public owner; //Owner is also a maintainer    
    ERC20 public MESA;
    
    
    struct User{        
        address ethAddress;
        string username;
        string name;
        string mail;
        string profileimgUrl;
        string profileCoverimgUrl;
        string bio;
        accountStatus status;      
    }
    
    struct Post{
        uint256 postId;
        address author;        
        string titleUrl;
        string descriptonUrl;
        string imgUrl;
        uint256 timestamp;
        uint256 upCount;
        uint256 downCount;
        uint256 reportCount; 
        uint8 postType;     
    }
    
    struct Comment{
        uint256 commentId;
        address author;
        uint256 postId;
        string contentUrl;
        string imgUrl;
        uint256 upCount;
        uint256 downCount;
        // uint256 reportCount;
        uint256 parentCommentId;
        uint256 timestamp;     
    }
    
    uint256 public totalPosts=0;
    uint256 public totalComments=0;
    uint256 public totalUsers=0;  

    uint256 public privatePostCost=3000;
    uint256 public paidPostCost=3000;
    uint256 public paidPostViewCost=3000;
    
    enum accountStatus{NP,Active,Banned,Deactivated}
    ///@dev NP means not present the default value for status  
    // enum postStatus{NP,Active, Banned, Deleted}
    
    mapping(address=>User) private users; //mapping to get user details from user address
    
    mapping(string=>address) private userAddressFromUsername;//to get user address from username
    // mapping(address=>bool) private registeredUser; //mapping to get user details from user address
    mapping(string=>bool) private usernames;//To check which username is taken taken=>true, not taken=>false

    
    mapping(uint256=>Post) private posts;// mapping to get post from Id
    mapping(uint256=>Post) private privatePosts;// mapping to get private post from Id
    mapping(uint256=>Post) private paidPosts;// mapping to get paid post from Id    
    mapping(uint256=>string) private privatePostKey; // mapping to get post private key state from Id   
    mapping(address=>uint256[ ]) private userPosts; // Array to store posts(Id) done by user
    mapping(address=>uint256[ ]) private userPrivatePosts; // Array to store private posts(Id) done by user
    mapping(address=>uint256[ ]) private userPaidPosts; // Array to store paid posts(Id) done by user
    // mapping(uint256=>address[]) private postLikersList;
    mapping(uint256=>mapping(address=>bool)) private postUpLikers; // Mapping to track who liked which post
    mapping(uint256=>mapping(address=>bool)) private postDownLikers; // Mapping to track who unliked which post

    mapping(address=>mapping(uint256=>bool)) private paidPostViewPermitted ;// Mapping user permit stated of paid post content
    
    mapping(uint256=>Comment) private comments; //Mapping to get comment from comment Id
    mapping(address=>uint256[ ]) private userComments;// Mapping to track user comments from there address    
    mapping(uint256=>mapping(address=>bool)) private commentUpLikers; //Mapping to track who liked on which comment
    mapping(uint256=>mapping(address=>bool)) private commentDownLikers; // Mapping to track who unliked which comment
    // mapping(uint256=>mapping(address=>bool)) private commentReporters; // Mapping to track who reported which comment 
    mapping(uint256=>uint256[ ]) private postComments; // Getting comments for a specific post
    mapping(uint256=>uint256[ ]) private commentSubComments; // Getting replycomments for a specific comment
       
    // modifier onlyOwner{require(msg.sender==owner,"You are not owner!"); _;}
    modifier onlyPostAuthor(uint256 id){require(msg.sender==posts[id].author,"You are not Author!"); _;}
    modifier onlyCommentAuthor(uint256 id){require(msg.sender==comments[id].author,"You are not Author!"); _;}
    modifier onlyAllowedUser(address user){require(users[user].status==accountStatus.Active,"Not a Registered User!"); _;}
    modifier onlyActivePost(uint256 id){//require(posts[id].status==cdStatus.Active,"Not a active post");
     _;}
    modifier onlyActiveComment(uint256 id){//require(comments[id].status==cdStatus.Active,"Not a active comment");
     _;}
    modifier usernameTaken(string memory username){require(!usernames[username],"Username already taken"); _;}
 // modifier checkUserExists(){require(registeredUser[msg.sender]); _;}
     modifier checkUserNotExists(address user){require(users[user].status==accountStatus.NP,"User already registered"); _;}

    
    event logRegisterUser(address user, uint256 id);
    event logUserBanned(address user, uint256 id);
    event logPostCreated(address author,  uint256 postid);
    event logPostDeleted(uint256 id, string hashtag);
    // event logCommentBanned(uint256 id, string hashtag);
    
    constructor() {
        // owner=msg.sender;
    
        registerUser("owner","owner","","","","owner");
        MESA=ERC20(address(0x067a37347f4188a0e16759303827d8143e0Ff0Df));
    }
    
    fallback() external{
        revert();
    }

    function compareStringsbyBytes(string memory s1, string memory s2) public pure returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }  
/*
**************************************USER FUNCTIONS********************************************************************************
*/

    /// @notice Check username available or not
    /// @param  _username username to Check
    /// @return status true or false
    function usernameAvailable(string memory _username) public view returns(bool status){
        return !usernames[_username];
    }
    
    /// @notice Register a new user
    /// @param  _username username of username
    /// @param _name name of person
    /// @param _imgUrl Ipfs Hash of users Profile Image
    /// @param _coverHash Ipfs Hash of user cover Image
    /// @param _bio Biography of user
    function registerUser(string memory _username, string memory _name,string memory _mail, string memory _imgUrl, string memory _coverHash, string memory _bio ) public  checkUserNotExists(msg.sender) usernameTaken(_username){
        usernames[_username]=true;// Attack Prevented
        totalUsers=totalUsers.add(1);            
        users[msg.sender]=User(msg.sender, _username, _name,_mail, _imgUrl, _coverHash, _bio, accountStatus.Active);        
        userAddressFromUsername[_username]=msg.sender;      
        emit logRegisterUser(msg.sender, totalUsers);
    }    

    
    /// @notice Change username of a user
    /// @param _username New username of user
    function changeUsername(string memory _username) public  onlyAllowedUser(msg.sender) usernameTaken(_username){
        users[msg.sender].username=_username;
    }    
    /// @notice Get user details
 
     
    function getUser(address _user) public view
    returns(string memory username,string memory name, string memory mail, string memory imgUrl, string memory coverimgUrl, string memory bio){
        return(users[_user].username,users[_user].name,  users[_user].mail, users[_user].profileimgUrl, users[_user].profileCoverimgUrl, users[_user].bio);
    }

  

/*
**************************************DWEET FUNCTIONS***********************************************************
*/      
    /// @notice Create a new post
    /// @param _titleUrl title Url of post ex. #ethereum
    /// @param _descriptonUrl descripton Url of post to show
    /// @param _imgUrl Image Url content ipfs hash
    /// @param _postType post type public private paid
    /// @param _privateKey private key in private post cae 
    function createPost(string memory _titleUrl, string memory _descriptonUrl, string memory _imgUrl, uint8 _postType, string memory _privateKey ) public  onlyAllowedUser(msg.sender) {
        if (_postType==1){//private post
            require(MESA.allowance(msg.sender,address(this))>=privatePostCost ,
                "there is no enough approved token amount for create private post");
            require(MESA.balanceOf(msg.sender)>=privatePostCost,
                "there is no enough token balance for create private post");
            MESA.transferFrom(msg.sender, address(this), privatePostCost);
        }
        if (_postType==2){//paid post
            require(MESA.allowance(msg.sender,address(this))>=paidPostCost ,
                "there is no enough approved token amount for create paid post");
            require(MESA.balanceOf(msg.sender)>=paidPostCost,
                "there is no enough token balance for create paid post");
             MESA.transferFrom(msg.sender, address(this), paidPostCost);
        }
        totalPosts=totalPosts.add(1);
        uint256 id=totalPosts;
        posts[id]=Post(id,msg.sender,_titleUrl,_descriptonUrl, _imgUrl,block.timestamp , 0, 0, 0,_postType);
        if (_postType==1){        
          privatePostKey[id]=_privateKey;
          userPrivatePosts[msg.sender].push(totalPosts);      
        }else if (_postType==2){        
          userPaidPosts[msg.sender].push(totalPosts);       
        }           
        userPosts[msg.sender].push(totalPosts);
        emit logPostCreated(msg.sender,  totalPosts);
    }
    
    /// @notice Ban Post Internal Function
    /// @param  _id Id of post
    // function banPost(uint256 _id) internal{
      
    //     delete posts[_id];
    //     //posts[_id].status=cdStatus.Banned;
    //     for(uint256 i=0;i<postComments[_id].length;i++){
    //         delete postComments[_id][i];
    //     }
    //     delete postComments[_id];
    // }
    
    /// @notice Edit a post 
    /// @param  _id Id of post
    /// @param  _hashtag New tag of post
    /// @param  _content New content of post
    /// @param  _imgUrl Hash of new image content
    // function editPost(uint256 _id, string memory _hashtag, string memory _content, string memory _imgUrl) public  onlyActivePost(_id)
    // onlyAllowedUser(msg.sender) onlyPostAuthor(_id) {
    //     posts[_id].hashtag=_hashtag;
    //     posts[_id].content=_content;
    //     posts[_id].imgUrl=_imgUrl;
    // }
    
    /// @notice Delete a post
    /// @param  _id Id of post
    // function deletePost(uint256 _id) public onlyActivePost(_id) onlyAllowedUser(msg.sender)  onlyPostAuthor(_id){
    //     emit logPostDeleted(_id, posts[_id].hashtag);
    //     delete posts[_id];
    //     //posts[_id].status=cdStatus.Deleted;
    //     for(uint256 i=0;i<postComments[_id].length;i++){
    //         delete postComments[_id][i];
    //     }
    //     delete postComments[_id];
    // }
    
    /// @notice Get a Posts array list
    /// @return postList Array of post ids
    /// @return privatePostList Array of private post ids
    /// @return paidPostList Array of paid post ids
   
    // function getPosts() public onlyAllowedUser(msg.sender)  view 
    // returns ( uint256[ ] memory postList,uint256[ ] memory privatePostList,uint256[ ] memory paidPostList){
        
    //     return (posts,privatePosts,paidPosts);
    // }

    ////@notice private 
    /// @param  _postId Id of post
    function paidPostViewPermit(uint256 _postId) public onlyAllowedUser(msg.sender) {
        require(MESA.allowance(msg.sender,address(posts[_postId].author))>=paidPostViewCost ,
                "there is no enough approved token amount for create private post");
        require(MESA.balanceOf(msg.sender)>=paidPostViewCost,
            "there is no enough token balance for create private post");
        MESA.transferFrom(msg.sender, address(this), paidPostViewCost);
        paidPostViewPermitted[msg.sender][_postId]=true;

    }

    /// @notice Get a Post
    /// @param  _id Id of post
    /// @param  _privatekey private key of post
    /// @return author Post author address    
    /// @return  titleUrl title ipfs Url of post
    /// @return  descriptonUrl Content ipfs Url of post
    /// @return  imgUrl Hash of image content
    /// @return  timestamp Post creation timestamp 
    function getPost(uint256 _id,string memory _privatekey) public onlyAllowedUser(msg.sender) onlyActivePost(_id) view 
            returns ( address author, string memory titleUrl, string memory descriptonUrl, string memory imgUrl, uint256 timestamp){
        if(posts[_id].postType==0||msg.sender==posts[_id].author){            
            return (posts[_id].author,  posts[_id].titleUrl, posts[_id].descriptonUrl, posts[_id].imgUrl, posts[_id].timestamp);
        }else if(posts[_id].postType==1){
            if(compareStringsbyBytes(privatePostKey[_id],_privatekey)){
                return (posts[_id].author,  posts[_id].titleUrl, posts[_id].descriptonUrl, posts[_id].imgUrl, posts[_id].timestamp);
            }else{
                return (posts[_id].author,  posts[_id].titleUrl, '','',0);
            }
        }else {
           if(paidPostViewPermitted[msg.sender][_id]){
                return (posts[_id].author,  posts[_id].titleUrl, posts[_id].descriptonUrl, posts[_id].imgUrl, posts[_id].timestamp);
           }else{
                return (posts[_id].author,  posts[_id].titleUrl, '','',0);
           }
        }
    }
    /// @notice Get a PostLikeCount
    /// @param  _id Id of post    
    /// @return  upCount count of like ups
    /// @return  downCount count of like downs

    function getPostLikeCount(uint256 _id) public onlyAllowedUser(msg.sender) onlyActivePost(_id) 
    view returns ( uint256 upCount, uint256 downCount ){
        return (posts[_id].upCount, posts[_id].downCount);
    }
    
    
    /// @notice Like a posts
    /// @param _id Id of post to be likePost
    function likeUpPost(uint256 _id) public onlyAllowedUser(msg.sender) onlyActivePost(_id){
        if(!postUpLikers[_id][msg.sender]){
            posts[_id].upCount=posts[_id].upCount.add(1);
            postUpLikers[_id][msg.sender]=true;
        }
        else{
            posts[_id].upCount=posts[_id].upCount.sub(1);
            postUpLikers[_id][msg.sender]=false;
        }
    }
    /// @notice unLike a posts
    /// @param _id Id of post to be unlikePost
    function likeDownPost(uint256 _id) public onlyAllowedUser(msg.sender) onlyActivePost(_id){
        if(!postDownLikers[_id][msg.sender]){
             posts[_id].downCount=posts[_id].downCount.add(1);
        postDownLikers[_id][msg.sender]=true;
        }else{
            posts[_id].downCount=posts[_id].downCount.sub(1);
            postDownLikers[_id][msg.sender]=false;
        }
    }    
    
    /// @notice Get list of posts done by a user
    /// @return postList Array of post ids
    /// @return privatePostList Array of private post ids
    /// @return paidPostList Array of paid post ids
    function getUserPosts() public view onlyAllowedUser(msg.sender) 
    returns(uint256[ ] memory postList,uint256[ ] memory privatePostList,uint256[ ] memory paidPostList){
                return (userPosts[msg.sender],userPrivatePosts[msg.sender],userPaidPosts[msg.sender]);
    }
    
    /// @notice Get list of posts done by a user
    /// @return postList Array of post ids
    /// @return privatePostList Array of private post ids
    /// @return paidPostList Array of paid post ids
    function getUserPosts(address _user) public view onlyAllowedUser(msg.sender)
     returns(uint256[ ] memory postList,uint256[ ] memory privatePostList,uint256[ ] memory paidPostList){
        require(_user!=address(0x0),"address is null address");
        return (userPosts[_user],userPrivatePosts[_user],userPaidPosts[_user]);
    }

/*
**************************************COMMENT FUNCTIONS*************************************************************************
*/ 
    /// @notice Create a comment on post
    /// @param  _postid Id of postList
    /// @param  _contentUrl content Url of comment
    /// @param  _imgUrl Image Url of comment
    /// @param  _commentid content of currentcomment
    /// @param  _privatekey private key of post
    function createComment(uint256 _postid,string memory _contentUrl,string memory _imgUrl,uint256 _commentid,string memory _privatekey) public  onlyAllowedUser(msg.sender)  onlyActivePost(_postid){
        require(_commentid>=0,"commentId must be euqaul or more than 0");
        if(posts[_postid].author!=msg.sender){
            if(posts[_postid].postType==1){
                require(compareStringsbyBytes(privatePostKey[_postid],_privatekey), "not correct private key");
            }else if(posts[_postid].postType==2){
                require(paidPostViewPermitted[msg.sender][_postid],"you are not permitted to view this post");
            }
        }
     
        totalComments=totalComments.add(1);
        uint256 id=totalComments;
        comments[id]=Comment(id, msg.sender, _postid, _contentUrl, _imgUrl,0,0,_commentid, block.timestamp);
        if(_commentid>0){
          commentSubComments[_commentid].push(totalComments);
        }else{
           userComments[msg.sender].push(totalComments);
           postComments[_postid].push(totalComments);
        }
       
    }
    
    // function banComment(uint256 _id) internal {
    //     emit logCommentBanned(_id, posts[comments[_id].postId].hashtag);
    //     delete comments[_id];
    //     comments[_id].status=cdStatus.Banned;
    // }
    
    
    /// @notice Get list of posts done by a user
    /// @param  _commentid Id of comments
    /// @param  _comment New content of comment
    // function editComment(uint256 _commentid, string memory _comment) public  onlyAllowedUser(msg.sender)  onlyActiveComment(_commentid) onlyCommentAuthor(_commentid){
    //     comments[_commentid].content=_comment;
    // }
    
    /// @notice Delete a comment
    /// @param _id Id of comment to be Deleted
    // function deleteComment(uint256 _id) public  onlyActiveComment(_id) onlyAllowedUser(msg.sender) onlyCommentAuthor(_id) {
    //     delete comments[_id];
    //     //comments[_id].status=cdStatus.Deleted;
    // }
    
    
    /// @notice Get a comment
    /// @param  _id Id of comment
    /// @return author Address of author
    /// @return postId Id of post 
    /// @return contentUrl content Url of comment 
    /// @return imgUrl image Url of comment  
    /// @return timestamp Comment creation timestamp  
    function getComment(uint256 _id, string memory _privatekey) public view onlyAllowedUser(msg.sender) onlyActiveComment(_id) 
    returns(address author, uint256 postId,  string memory contentUrl,string memory imgUrl,uint256 timestamp){
        if(posts[comments[_id].postId].author!=msg.sender){
            if(posts[comments[_id].postId].postType==1){
                require(compareStringsbyBytes(privatePostKey[comments[_id].postId],_privatekey), "not correct private key");
            }else if(posts[comments[_id].postId].postType==2){
                require(paidPostViewPermitted[msg.sender][comments[_id].postId],"you are not permitted to view this post");
            }
        }
        return(comments[_id].author, comments[_id].postId, comments[_id].contentUrl,comments[_id].imgUrl, comments[_id].timestamp);
    }
    /// @notice Get a comment
    /// @param  _id Id of comment  
    /// @return upCount upCount on commment
    /// @return downCount downCount on commment
   
    function getCommentLikeCount(uint256 _id) public view onlyAllowedUser(msg.sender) onlyActiveComment(_id) 
    returns( uint256 upCount, uint256 downCount){
        return(comments[_id].upCount, comments[_id].downCount);
    }
    
    /// @notice Get comments done by user
    /// @return commentList Array of comment ids
    /// @dev Though onlyAllowedUser can be bypassed easily but still keeping for calls from frontend 
    function getUserComments() public view onlyAllowedUser(msg.sender) returns(uint256[ ] memory commentList){
        return userComments[msg.sender];
    }
    
    /// @notice Get comments done by user
    /// @param _user address of user
    /// @return commentList Array of comment ids
    function getUserComments(address _user) public view onlyAllowedUser(msg.sender) returns(uint256[ ] memory commentList){
        return userComments[_user];
    }
    
    /// @notice Get comments on a post
    /// @return list Array of comment ids
    // function getPostComments(uint256 _id) public view onlyAllowedUser(msg.sender) onlyActivePost(_id) returns(uint256[ ] memory list){
    //     //require(!privatePostState[_id] , "this is private post");
    //     return(postComments[_id]);
    // }
    function getPostComments(uint256 _postid, string memory _privatekey) public view onlyAllowedUser(msg.sender) onlyActivePost(_postid) returns(uint256[ ] memory list){
         if(posts[_postid].author!=msg.sender){
            if(posts[_postid].postType==1){
                require(compareStringsbyBytes(privatePostKey[_postid],_privatekey), "not correct private key");
            }else if(posts[_postid].postType==2){
                require(paidPostViewPermitted[msg.sender][_postid],"you are not permitted to view this post");
            }
        }
        return(postComments[_postid]);
    }
       /// @notice Like a posts
    /// @param _id Id of post to be likePost
    function likeUpComment(uint256 _id) public onlyAllowedUser(msg.sender) onlyActiveComment(_id){
        if(!commentUpLikers[_id][msg.sender]){
            comments[_id].upCount=comments[_id].upCount.add(1);
            commentUpLikers[_id][msg.sender]=true;
        }
        else{
            comments[_id].upCount=comments[_id].upCount.sub(1);
            commentUpLikers[_id][msg.sender]=false;
        }
    }
    /// @notice unLike a posts
    /// @param _id Id of post to be unlikePost
    function likeDownComment(uint256 _id) public onlyAllowedUser(msg.sender) onlyActiveComment(_id){
        if(commentDownLikers[_id][msg.sender]){
            comments[_id].upCount=posts[_id].downCount.sub(1);
            commentDownLikers[_id][msg.sender]=false;
        }else{
            comments[_id].upCount=posts[_id].downCount.add(1);
            commentDownLikers[_id][msg.sender]=true;

        }
     
    }      
/*
**********************************Reporting And Maintanining*****************************************************************************************
*/
        
/*
*******************************************Advertisement **************************************************************
*/



/*
****************************************Owner Admin ******************************************************************************************
*/
    /// @notice Get balance of contract 
    /// @return balance balance of contract
    function getBalance()public view onlyOwner() returns(uint256 balance){
        return address(this).balance;
    }
    
    /// @notice Withdraw contract funds to owner
    /// @param _amount Amount to be withdrawn
    function transferContractBalance(uint256 _amount)public onlyOwner{
        require(_amount<=address(this).balance,"Withdraw amount greater than balance");
        msg.sender.transfer(_amount);
    }
    

    
    // function changeOwner(address payable _newOwner) public onlyOwner{
    //     owner=_newOwner;
    // }
    
}