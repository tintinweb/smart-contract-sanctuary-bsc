pragma solidity ^0.5.0;

contract Quiz {
   // Structure of a Question
   // Each Question has four answer choices and only one correct anser choice
   struct Question {
      string question;
      string correctAns;
      string wrongAns1;
      string wrongAns2;
      string wrongAns3;
   }

   // Structure of a Quiz
   struct QuizEvent {
      uint id;
      address creator;
      string name;
      uint fee;
      uint pool;
      Question q1;
      mapping(address => bool) hasPaid;
      mapping(address => bool) attempts;
   }

   // Structure of a displayable quizzes
   // Stores the same information as a quiz except for question information
   struct QuizDisplayable {
      uint id;
      string name;
      uint fee;
      uint pool;
      mapping(address => bool) attempts;
   }

   mapping(uint => QuizEvent) quizzes;
   mapping(uint => QuizDisplayable) quizDisp;

   uint public numQuizzes;

   event fetchquiz (uint indexed _quizId);   // get quiz questions
   event quiztaken (uint indexed _quizId);   // quiz answers submitted

   // Upon contract creation, initialize number of quizzes to 0 and create a new Quiz Event
   constructor () public {
      numQuizzes = 0;
      makeQuiz("Test Quiz", 1, 0, "2+2=", "4", "3", "5", "2");
   }

   // Increment number of quizzes
   // Create a new QuizEvent and add it to the list of quizzes
   // Create a new QuizDisplayable and add it to the list of displayable quizzes
   // Add the creator as a user who has attempted so the creator cannot attempt the quiz
   function makeQuiz (string memory _name, uint _fee, uint _pool, string memory _question, string memory _ans1, string memory _ans2, string memory _ans3, string memory _ans4) public {
      numQuizzes ++;
      quizzes[numQuizzes] = QuizEvent(numQuizzes, msg.sender,_name, _fee, _pool, Question(_question, _ans1, _ans2, _ans3, _ans4));
      quizDisp[numQuizzes] = QuizDisplayable(numQuizzes, _name, _fee, _pool);
      quizzes[numQuizzes].attempts[msg.sender] = true;
   }

   // Returns quiz information for _quizId without returning the questions
   function getQuizDisp(uint _quizId) view public returns(uint, string memory, uint, uint) {
      QuizDisplayable memory temp = quizDisp[_quizId];
      return (temp.id,temp.name,temp.fee,temp.pool);
   }

   // Adds the user to the list of users who have attemped this quiz
   function setAttempt(uint _quizId) public {
      quizzes[_quizId].attempts[msg.sender] = true;
   }

   // Checks to see if the user has paid but has not attempted
   // This is used to bypass the front-end form to submit the fee
   function canSkip(uint _quizId) view public returns (bool) {
      bool skip = quizzes[_quizId].hasPaid[msg.sender] && !quizzes[_quizId].attempts[msg.sender];
      return skip;
   }

   // Requires that the quiz event exists
   // Requires that the account trying to access the quiz information has not taken it before
   // Once the account receives the quiz, add the account to the list of accounts that have attempted this quiz
   function getQuiz (uint _quizId) view public returns (string memory, string memory, string memory, string memory, string memory) {
      require(_quizId > 0 && _quizId <= numQuizzes);
      require(!quizzes[_quizId].attempts[msg.sender]);
      Question memory q = quizzes[_quizId].q1;
      return (q.question, q.correctAns, q.wrongAns1, q.wrongAns2, q.wrongAns3);
   }

   // Requires that the quiz exists
   // Requires that the account has not attempted the quiz before
   // Allows users to send money
   // The contract's account balance will hold all of the ether for all QuizEvent pools
   // Require that amount paid is greater than equal to current amount in Pool
   // Add fee to the pool of _quizId
   // Add the user to the mapping hasPaid to indicate that the user has paid the appropriate fee to take the quiz
   // Fetch the quiz for the user to access.
   function payToPlay (uint _quizId) public payable {
      require(_quizId > 0 && _quizId <= numQuizzes); //checks if quiz exist
      require(!quizzes[_quizId].attempts[msg.sender]); //checks if they have not attempted
      require(msg.value >= quizzes[_quizId].fee);//if they paid the right amount
      quizzes[_quizId].pool += msg.value;
      quizzes[_quizId].hasPaid[msg.sender] = true;
      emit fetchquiz(_quizId);
   }

   // Returns the number of QuizEvents
   function getNum() public view returns (uint) {
       return numQuizzes;
   }

   // Requires that the quiz exists
   // Returns the current pool amount of the QuizEvent _quizId
   //Nice to show the user how much reward a certain quiz has
   function getPoolAmount (uint _quizId) view public returns (uint) {
      require(_quizId > 0 && _quizId <= numQuizzes); //checking if quiz exosts
      return quizzes[_quizId].pool; //returns pool balance
   }

   // Requires that the quiz event exists
   // Requires that the account has paid the fee to attempt the quiz
   // Requires that the account has attempted the quiz
   // Hashes the question's correct answer and the answer submitted by the account and compares the two Hashes
   // If the two hashes are equal, then return true, otherwise false
   function scoreAttempt (uint _quizId, string memory _ans) view public returns (bool) {
      require(_quizId > 0 && _quizId <= numQuizzes);
      require(quizzes[_quizId].hasPaid[msg.sender]);
      require(quizzes[_quizId].attempts[msg.sender]);

      return (keccak256(abi.encodePacked(_ans)) == keccak256(abi.encodePacked(quizzes[_quizId].q1.correctAns)));
   }

   // Requires that the account has paid the fee to attempt the quiz
   // Requires that the account has attempted the quiz
   // Transfer the amount of ether in the pool of _quizId to the winner
   // Set the _quizId pool amount to 0
   function awardLottery (uint _quizId, address payable _winner) public {
      require(quizzes[_quizId].hasPaid[_winner]);
      require(quizzes[_quizId].attempts[_winner]);
      _winner.transfer(quizzes[_quizId].pool);
      quizzes[_quizId].pool = 0;
   }
}