class MessagesController < ApplicationController
    def index
        page = (params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1)
        limit = (params[:limit] && params[:limit].to_i > 0 ? params[:limit].to_i : 10)
        offset = (page - 1) * limit
        total_count = Message.count
        count_pages = total_count / limit

        total_pages = (total_count % limit === 0 ? count_pages : count_pages + 1)

        messages = Message
            .order(created_at: :desc)
            .limit(limit)
            .offset(offset)

        render json: {
            messages: messages,
            meta: {
                page: page,
                total_pages: total_pages,
                total_count: total_count,
                limit: limit
            }
        }
    end

    def create
        message = Message.create!(message_params)
        if message.valid?
            ActionCable.server.broadcast("messages_channel", message)
            render json: { message: message },
            status: :created
        else
            render json: { errors: message.errors.full_messages },
            status: :unprocessable_entity
        end
    end

    private

    def message_params
        params.require(:message).permit(:content, :user)
    end
end
