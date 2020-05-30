require 'rails_helper'

RSpec.describe "Users", type: :request do
    describe 'Get /users/new' do
        subject { get new_user_path}
        before do
            subject
        end

        it 'レスポンスコードが200であること' do
            expect(response).to have_http_status(:ok)
        end

        it 'newテンプレートをレンダリングすること' do
            expect(response).to render_template :new
        end

        it '新しいuserオブジェクトがビューに渡されること' do
            expect(assigns(:user)).to be_a_new User
        end
    end

    describe 'Post #create' do
        before do
            @referer = 'http://www.example.com/'
        end

        context '正しいユーザー情報が渡って来た場合' do
            let(:params) do
                { user: {
                    name: 'user',
                    password: 'password',
                    password_confirmation: 'password',
                    }
                }
            end

            it 'ユーザーが一人増えていること' do
                expect do
                    post '/users', params: params
                end.to change(User, :count).by(1)
            end

            it 'マイページにリダイレクトされること' do
                expect( post '/users', params: params).to redirect_to(mypage_path)
            end
        end

        context 'パラメーターに正しいユーザー名、確認パスワードが含まれていない場合' do
            before do
                post('/users', params: {
                    user: {
                        name: 'ユーザー１',
                        password: 'password',
                        password_confirmation: 'invalid password'
                    }
                })
            end

            it 'リファラーにリダイレクトされること' do
                request.env["HTTP_REFERER"] = @referer
                expect(response).to redirect_to(@referer)
            end

            it 'ユーザー名のエラーメッセージが含まれていること' do
                request.env["HTTP_REFERER"] = @referer
                expect(flash[:error_messages]).to include 'ユーザー名は小文字英数字で入力してください'
            end

            it 'パスワード確認のエラーメッセージが含まれていること' do
                request.env["HTTP_REFERER"] = @referer
                expect(flash[:error_messages]).to include 'パスワード（確認）とパスワードの入力が一致しません'
            end
        end
    end
end
