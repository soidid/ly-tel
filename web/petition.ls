{ div, img, form, button, label, input, span, em } = React.DOM

firebaseApp = 'https://99fireman.firebaseio.com/'

PetitionApp = React.createClass do
  displayName: 'PetitionApp'
  mixins: [ReactFireMixin]
  getInitialState: -> { data: [], user: null, isPetitioned: false}
  componentWillMount: ->
    @bindAsArray (new Firebase "#{firebaseApp}/issues/fireman-owyeu8i3t7l7rves/petitioners"), 'data'
    @auth = new FirebaseSimpleLogin @firebaseRefs['data'], (error, user) ~>
      return console error if error
      if user
        { uid } = user
        @setState user: user
        ref = @firebaseRefs.data.child "#{uid}" #startAt user.uid .endAt user.uid
        ref.on 'child_added', ~>
          if it.val!
            @setState isPetitioned: true
      else
        @setState user: null

  handlePetitionSubmit: ({uid, email}:petition) ->
    delete petition.email
    petitioners = @state.data
    petitioners.push petition
    @setState data: petitioners
    @firebaseRefs.data.child "#{uid}" .setWithPriority petition, Firebase.ServerValue.TIMESTAMP
    @firebaseRefs.data.root().child "users/#{uid}" .setWithPriority email: email, Firebase.ServerValue.TIMESTAMP
  handleLogin: ->
    @auth.login 'facebook', do
      rememberMe: true
      scope: 'email'
  handleLogout: ->
    @auth.logout!
  render: ->
    div {},
      unless @state.user
        FBAuthButton handleClick: @handleLogin, message: '臉書登入'
      else
        FBAuthButton handleClick: @handleLogout, message: '臉書登出'
      if @state.user and !@state.isPetitioned
        PetitionForm do
          onPetitionSubmit: @handlePetitionSubmit
          uid: @state.user.uid
          displayName: @state.user.displayName
          email: @state.user.thirdPartyUserData.email
          avatarURL: @state.user.thirdPartyUserData.picture.data.url
      div {className: 'done'}, '我已連署過' if @state.isPetitioned and @state.user
      PetitionList data: @state.data


PetitionList = React.createClass do
  displayName: 'PetitionList'
  render: ->
    count = 0
    personNodes = @props.data.map ({displayName, avatarURL, hiddenMe}:petitioner) ->
      unless hiddenMe
        count := count + 1
        Petitioner author: displayName, avatar: avatarURL
    div {className: 'petition-list'},
      div {className: 'issue-petitioners'}, "目前已經有 #{@props.data.length} 人連署"
      div {className: 'petitioners'}, { personNodes },
        span {className: 'more'}, "...以及其他#{@props.data.length - count}人。" if @props.data.length - count > 0

Petitioner = React.createClass do
  displayName: 'PetitionPerson'
  componentDidMount: ->
    $ @getDOMNode! .popup!#if @Mounted!
  render: ->
    _displayName = @props.author
    _displayName = "#{@props.author.substring(0,15)}..." if @props.author.length >= 15
    div {className: 'petitioner', 'data-content': @props.author },
      img { src: @props.avatar }
      div {className: 'name' }, _displayName

FBAuthButton = React.createClass do
  displayName: 'FBAuthButton'
  render: ->
    return button {onClick: @props.handleClick}, @props.message

PetitionForm = React.createClass do
  displayName: 'PetitionForm'
  getInitialState: ->
    return do
      displayName: @props.displayName || ''
      email: @props.email || ''
      uid: @props.uid || ''
      avatarURL: @props.avatarURL || ''
      hiddenMe: false
  handleNameChange: ->
    @setState displayName: it.target.value
  handleEmailChange: ->
    @setState email: it.target.value
  handleDisplayCheck: ->
    @setState hiddenMe: it.target.checked
  handleSubmit: ->
    it.preventDefault!
    {displayName, email, uid, avatarURL, hiddenMe} = @state
    console.log hiddenMe
    return unless displayName or email or uid or avatarURL
    displayName .= trim!
    @props.onPetitionSubmit do
      displayName: displayName
      email: email
      uid: uid
      avatarURL: avatarURL
      hiddenMe: hiddenMe
  render: ->
    form { onSubmit: @handleSubmit },
      div {className: 'field'},
        label {}, '顯示名稱'
        input {type: 'text', value: @state.displayName, onChange: @handleNameChange }
      div {className: 'field'},
        label {}, 'Email'
        input {type: 'email', value: @state.email, onChange: @handleEmailChange }
      div {className: 'field'},
        input {type: 'checkbox', checked: @state.hiddenMe, onChange: @handleDisplayCheck }, '不要顯示頭像'
      input {type: 'hidden', value: @state.uid }
      input {type: 'hidden', value: @state.avatarURL }
      button { type: 'submit', onSubmit: @handleSubmit }, '我要連署'

React.renderComponent PetitionApp!, document.getElementById 'petition_component'
