User.create!([
  {doc_file_name: nil, doc_content_type: nil, doc_file_size: nil, doc_updated_at: nil, email: "andrewnguyen@adelaide.edu.au", encrypted_password: "$2a$10$O7iOm4wun0mA.Qv1dLf2kuUtS2Rd9fU0SorLWjal4ny5zHRnRxfq.", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-17 00:09:03", last_sign_in_at: "2015-02-17 00:09:03", current_sign_in_ip: "::1", last_sign_in_ip: "::1"},
  {doc_file_name: nil, doc_content_type: nil, doc_file_size: nil, doc_updated_at: nil, email: "marcfarmer@adelaide.edu.au", encrypted_password: "$2a$10$CxmybvrE0iaZ3dQh8BOjXuQC2INweJLLONlsm8Tb1IyQvTJyuho6u", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-17 00:13:06", last_sign_in_at: "2015-02-17 00:13:06", current_sign_in_ip: "::1", last_sign_in_ip: "::1"},
  {doc_file_name: nil, doc_content_type: nil, doc_file_size: nil, doc_updated_at: nil, email: "davidphuong@adelaide.edu.au", encrypted_password: "$2a$10$WrTbxIvgbDlETiR1hmoK7eALtBIv/pgw30WqohbRcQHmZdd0XHRpS", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-17 00:16:14", last_sign_in_at: "2015-02-17 00:16:14", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1"}
])
Organisation.create!([
  {name: "Adelaide University", user_id: 1}
])
OrganisationUser.create!([
  {accepted: true, user_type: 0, user_id: 1, organisation_id: 1, inviter_id: 1},
  {accepted: true, user_type: 0, user_id: 2, organisation_id: 1, inviter_id: 1},
  {accepted: true, user_type: 1, user_id: 3, organisation_id: 1, inviter_id: 2}
])
