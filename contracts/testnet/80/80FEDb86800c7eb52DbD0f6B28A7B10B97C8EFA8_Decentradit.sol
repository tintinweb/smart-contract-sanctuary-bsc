/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Decentradit {
    event PostCreated(
        bytes32 indexed postId,
        address indexed postOwner,
        uint256 indexed serialNo,
        bytes32 contentId,
        bytes32 categoryId,
        uint256 minVotes
    );
    event CategoryCreated(bytes32 indexed categoryId, string category);
    event Voted(
        bytes32 indexed postId,
        address indexed postOwner,
        address indexed voter,
        uint80 reputationPostOwner,
        uint80 reputationVoter,
        uint256 postVotes,
        bool up,
        uint8 reputationAmount
    );
    // Minimum token to create a post
    uint256 public minTokenPost;
    uint256 public categoryCount;
    string[] public category; //= [string("null")];
    string[] public title;// = [string("null")];


    // Minimum token to vote a post
    uint256 public minTokenVotes;

    // Governance Token
    IBEP20 public token;

    address public owner;

    struct postNo {
        bool postDelete;
    }
   

    struct post {
        bytes32 postId;
        address postOwner;
        uint256 postCreatedTime;
        uint256 serialNo;
        string title;
        string  postUri; 
        uint256 upVotes;
        uint256 downVotes;
        uint256 totalVotes;
        bytes32 categoryId;
        bool timeDependent;
        uint256 endTime;
        uint256 minVotes;
        bool pass;
    }
  

     post[] public postList; 

     uint256 public totalPost;
    mapping(bytes32 => postNo) postResult;
    mapping(address => mapping(bytes32 => uint80)) reputationRegistry;
    mapping(bytes32 => string) categoryRegistry;
    mapping(bytes32 => string) contentRegistry;
    mapping(bytes32 => post) postRegistry;
    mapping(address => mapping(bytes32 => bool)) voteRegistry;
    mapping(bytes32 => uint256) postCounts;


    constructor(
        address _token,
        uint256 _minTokenPost,
        uint256 _minTokenVote
    ) {
        owner = msg.sender;
        token = IBEP20(_token);
        minTokenPost = _minTokenPost;
        minTokenVotes = _minTokenVote;
    }

    function createPost(
        string calldata _title,
        string calldata _contentUri,
        string calldata _postUri,
        bytes32 _categoryId,
        bool _timeDependent,
        uint256 _timePeriod,
        uint256 _minVotes
    ) external {
        require(
            minTokenPost <= token.balanceOf(msg.sender),
            " minimum token balance is needed to create post"
        );
        address _owner = msg.sender;
        bytes32 _contentId = keccak256(abi.encode(_contentUri));
        bytes32 _postId = keccak256(
            abi.encodePacked(_owner, _contentId)
        );
        contentRegistry[_contentId] = _contentUri;
        postRegistry[_postId].postUri = _postUri;
        postRegistry[_postId].postId = _postId;
        postRegistry[_postId].postOwner = _owner;
        postRegistry[_postId].postCreatedTime = block.timestamp;
        uint tPost = totalPost;
        postRegistry[_postId].serialNo = tPost;
        postRegistry[_postId].minVotes = _minVotes;
        postRegistry[_postId].title = _title;
        postRegistry[_postId].categoryId = _categoryId;
        postRegistry[_postId].timeDependent = _timeDependent;

        if (_timeDependent == true) {
            postRegistry[_postId].endTime = block.timestamp + _timePeriod;
        }
        postCounts[_categoryId]++;
        totalPost ++;
        postList.push(postRegistry[_postId]);
        emit PostCreated(_postId, _owner, tPost, _contentId, _categoryId ,_minVotes);
    }
 
    function voteUp(bytes32 _postId, uint8 _reputationAdded) external {
        require(postResult[ _postId].postDelete == false, "post has deleted");
        require(
            minTokenVotes <= token.balanceOf(msg.sender),
            " minimum token balance is needed for vote"
        );
        if (postRegistry[_postId].timeDependent == true) {
            require(
                block.timestamp <= postRegistry[_postId].endTime,
                " time is up for vote"
            );
        }
        address _voter = msg.sender;
        bytes32 _category = postRegistry[_postId].categoryId;
        address _contributor = postRegistry[_postId].postOwner;
        require(
            postRegistry[_postId].postOwner != _voter,
            "you cannot vote your own posts"
        );
        require(
            voteRegistry[_voter][_postId] == false,
            "Sender already voted in this post"
        );
        require(
            validateReputationChange(_voter, _category, _reputationAdded) ==
                true,
            "This address cannot add this amount of reputation points"
        );
        postRegistry[_postId].upVotes += 1;
        reputationRegistry[_contributor][_category] += _reputationAdded;
        voteRegistry[_voter][_postId] = true;
        postRegistry[_postId].totalVotes++;
        uint num = postRegistry[_postId].serialNo; 
        postList[num].upVotes ++;
        postList[num].totalVotes  ++;
         if (  postRegistry[_postId].upVotes >= postRegistry[_postId].minVotes || postList[num].upVotes >= postList[num].minVotes) {
          postRegistry[_postId].pass = true ;
          postList[num].pass = true;
       }
        emit Voted(
            _postId,
            _contributor,
            _voter,
            reputationRegistry[_contributor][_category],
            reputationRegistry[_voter][_category],
            postRegistry[_postId].upVotes,
            true,
            _reputationAdded
        );
    }

    function voteDown(bytes32 _postId, uint8 _reputationTaken) external {
        require(postResult[ _postId].postDelete == false, "post has deleted");
        require(
            minTokenVotes <= token.balanceOf(msg.sender),
            " minimum token balance is needed for vote"
        );
        if (postRegistry[_postId].timeDependent == true) {
            require(
                block.timestamp <= postRegistry[_postId].endTime,
                " timeis up for vote"
            );
        }
        address _voter = msg.sender;
        bytes32 _category = postRegistry[_postId].categoryId;
        address _contributor = postRegistry[_postId].postOwner;
        require(
            voteRegistry[_voter][_postId] == false,
            "Sender already voted in this post"
        );
        require(
            postRegistry[_postId].postOwner != _voter,
            "you cannot vote your own posts"
        );
        require(
            validateReputationChange(_voter, _category, _reputationTaken) ==
                true,
            "This address cannot take this amount of reputation points"
        );
        postRegistry[_postId].downVotes += 1;
             reputationRegistry[_contributor][_category] >= _reputationTaken
            ? reputationRegistry[_contributor][_category] -= _reputationTaken
            : reputationRegistry[_contributor][_category] = 0;
        voteRegistry[_voter][_postId] = true;
        postRegistry[_postId].totalVotes++;
        uint num = postRegistry[_postId].serialNo ; 
        postList[num].downVotes ++;
        postList[num].totalVotes  ++;
        emit Voted(
            _postId,
            _contributor,
            _voter,
            reputationRegistry[_contributor][_category],
            reputationRegistry[_voter][_category],
            postRegistry[_postId].downVotes,
            false,
            _reputationTaken
        );
    }

   function viewDeleteandResult( bytes32 _postId ) public view returns (uint vote , bool finish , bool _postdelete){
      vote = postRegistry[_postId].minVotes ; 
      _postdelete = postResult[ _postId].postDelete;
    if (postRegistry[_postId].upVotes < postRegistry[_postId].minVotes){
        return (vote ,false , _postdelete );
    }
    if (postRegistry[_postId].upVotes >= postRegistry[_postId].minVotes){
        return (vote ,true , _postdelete);
    }

   }

   function deletePost(uint256 index , bytes32 _postId ) public {
  require(owner == msg.sender, " caller is not an owner");
  require (postRegistry[_postId].serialNo == index ,"serial no and post id not matches");
    postList[index] = postList[postList.length -1];
    postList.pop();
    postResult[_postId].postDelete = true; 

}

    function validateReputationChange(
        address _sender,
        bytes32 _categoryId,
        uint8 _reputationAdded
    ) internal view returns (bool _result) {
        uint80 _reputation = reputationRegistry[_sender][_categoryId];
        if (_reputation < 2) {
            _reputationAdded == 1 ? _result = true : _result = false;
        } else {
            2**_reputationAdded <= _reputation
                ? _result = true
                : _result = false;
        }
    }

    function getEncoded(string memory _string) public pure returns (bytes32 titleId){
        bytes32 _categoryId = keccak256(abi.encode(_string));
        return _categoryId;
    }

    function addCategory(string calldata _category) external {
        require(
            minTokenPost <= token.balanceOf(msg.sender),
            " minimum token balance is needed to create caterory"
        );
        bytes32 _categoryId = keccak256(abi.encode(_category));
        categoryRegistry[_categoryId] = _category;
        categoryCount++;
        category.push(_category);
        emit CategoryCreated(_categoryId, _category);
    }

    function getCategoryCount() public view returns (uint256) {
        return categoryCount;
    }

    function getAllCategory() public view returns (string[] memory) {
        return category;
    }

    function getAllPosts() public view returns (post[] memory) {
        return postList;
    }

    function getPostCountperCategory(bytes32 _categoryId)
        public
        view
        returns (uint256)
    {
        return postCounts[_categoryId];
    }

    function getContent(bytes32 _contentId)
        public
        view
        returns (string memory)
    {
        return contentRegistry[_contentId];
    }

    function getCategory(bytes32 _categoryId)
        public
        view
        returns (string memory)
    {
        return categoryRegistry[_categoryId];
    }

    function getReputation(address _address, bytes32 _categoryID)
        public
        view
        returns (uint80)
    {
        return reputationRegistry[_address][_categoryID];
    }

    function getVoteRegistry(address _address, bytes32 _postId)
        public
        view
        returns (bool)
    {
        return voteRegistry[_address][_postId];
    }

    function getBalance(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }

    function changeMinTokenPost(uint256 amount) public {
        require(owner == msg.sender, " caller is not an owner");
        minTokenPost = amount;
    }

    function changeMinTokenVotes(uint256 amount) public {
        require(owner == msg.sender, " caller is not an owner");
        minTokenVotes = amount;
    }

    function getPost(bytes32 _postId)
        public
        view
        returns (
            address,
            uint256,
            string memory,
            uint256,
            uint256,
            uint256,
            bytes32
        )
    {
        return (
            postRegistry[_postId].postOwner,
            postRegistry[_postId].serialNo,
            postRegistry[_postId].title,
            postRegistry[_postId].upVotes,
            postRegistry[_postId].downVotes,
            postRegistry[_postId].totalVotes,
            postRegistry[_postId].categoryId

        );
    }

}